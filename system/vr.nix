{pkgs, ...}: let
  holoToggles = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "holo-realtek-firmware-toggles";
    version = "1.3-3";
    # Valve's SteamOS source mirror keeps every release, so this URL stays valid.
    src = pkgs.fetchurl {
      url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/holo-main/${pname}-${version}.src.tar.gz";
      hash = "sha256-ZnUx/MO9ATYPA/m3+5G3qYx42lJ5Ma2uoCwvudIrtCI=";
    };
    nativeBuildInputs = [pkgs.makeWrapper];
    installPhase = ''
      install -Dm755 ${pname} $out/bin/${pname}
      # Needs compgen, which the default non-interactive bash is built without
      substituteInPlace $out/bin/${pname} --replace-fail "#!/bin/bash" "#!${pkgs.bashInteractive}/bin/bash"
      wrapProgram $out/bin/${pname} \
        --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [coreutils findutils gnugrep iw])}
    '';
  };

  # Steam looks for the helper at this path inside its FHS env and calls it with
  # `set-low-latency-mode on|off`. Upstream re-execs itself via pkexec, which can't
  # work from the sandbox, so hand off to a root unit instead.
  holoShim = pkgs.writeTextFile {
    name = "holo-realtek-firmware-toggles-shim";
    destination = "/bin/holo-polkit-helpers/holo-realtek-firmware-toggles";
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      mode=off
      [ "$1 ''${2:-}" = "set-low-latency-mode on" ] && mode=on
      exec ${pkgs.systemd}/bin/systemctl start "steam-frame-low-latency@$mode.service"
    '';
  };
in {
  # The Steam Frame's 6 GHz adapter (rtw89_8852cu) stays off 6 GHz without a regdomain.
  boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=LV";

  programs.steam = {
    extraPackages = [holoShim];
    # DMS launches apps with QT_QPA_PLATFORM="wayland;xcb"; vrmonitor's bundled Qt5 has only
    # xcb and can't parse the list, so it aborts and vrserver shuts down 80s later.
    package = pkgs.steam.override {extraEnv.QT_QPA_PLATFORM = "xcb";};
  };

  # Upstream's `set-low-latency-mode on` minus the static -75 dBm packet-detection
  # threshold, which leaves the adapter deaf on signal fades (SteamVR-for-Linux#965).
  systemd.services."steam-frame-low-latency@" = {
    description = "Steam Frame adapter low-latency mode %i";
    path = [holoToggles pkgs.iw pkgs.gnugrep];
    serviceConfig.Type = "oneshot";
    # Steam fires `off` several times a second while (re)connecting
    unitConfig.StartLimitIntervalSec = 0;
    scriptArgs = "%i";
    script = ''
      if [ "$1" != on ]; then
        exec holo-realtek-firmware-toggles reset
      fi
      holo-realtek-firmware-toggles set-feature HW_SCAN off
      holo-realtek-firmware-toggles set-amsdu off
      # rtw89 oopses on `iw set bitrates` while unassociated
      if iw dev | grep -q "ssid frame_"; then
        holo-realtek-firmware-toggles set-mcs-rates 0-9
      fi
      holo-realtek-firmware-toggles set-powersave off
      holo-realtek-firmware-toggles set-aggressive-edca on
    '';
  };

  security = {
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("verb") == "start" &&
            /^steam-frame-low-latency@(on|off)\.service$/.test(action.lookup("unit")) &&
            subject.isInGroup("users") && subject.local && subject.active) {
          return polkit.Result.YES;
        }
      });
    '';

    # SteamVR/vrlink spawn an RT thread per network interface; the defaults (15 procs / 25 threads) run out
    rtkit.args = ["--processes-per-user-max=64" "--threads-per-user-max=128"];

    # Default is nice 0 / rtprio 0: Alyx's AudioMixer thread and SteamVR can't raise their own
    # priority, which makes Alyx's audio crackle under render load.
    pam.loginLimits = [
      {
        domain = "@users";
        type = "-";
        item = "rtprio";
        value = 20;
      }
      {
        domain = "@users";
        type = "-";
        item = "nice";
        value = -15;
      }
    ];
  };
}
