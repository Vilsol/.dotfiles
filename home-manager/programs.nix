{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  # The capture device EasyEffects pins in its own config (StreamInputs/inputDevice).
  easyeffectsInput = "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8_2017_9_29_80297-00.analog-stereo";

  # Ordering after wireplumber only guarantees the session manager started, not
  # that USB enumeration finished, so block on the node actually existing.
  # Always exits 0: a missing mic must not wedge the boot.
  waitForNode = pkgs.writeShellScript "wait-for-pw-node" ''
    for _ in $(seq 100); do
      if ${pkgs.pipewire}/bin/pw-cli ls Node 2>/dev/null | grep -qF "$1"; then exit 0; fi
      sleep 0.2
    done
    echo "wait-for-pw-node: '$1' never appeared after 20s, starting anyway" >&2
  '';
in {
  imports = [inputs.lan-mouse.homeManagerModules.default];

  home.packages = with pkgs;
    [
      # chromium
      fontconfig
      gimp
      dconf-editor
      # gnome-tweaks
      # jellyfin-media-player
      libreoffice-fresh
      pavucontrol
      remmina
      vlc
      # easyeffects
      spotify
      deskflow
      obsidian
      pwvucontrol
      chromium
      termscp
      ddcutil
      ddcui
      claude-desktop
      bubblewrap # cowork-mode sandbox backend for claude-desktop
    ]
    ++ lib.optionals config.my.fullDesktop [
      # handbrake
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      # davinci-resolve
    ];

  services.easyeffects.enable = true;

  # The upstream unit orders itself only after graphical-session.target, so at
  # boot it beats the audio stack (measured: 256ms before pipewire.service,
  # 2.1s before pipewire-pulse) and binds its input pipeline to a mic that does
  # not exist yet -- hence needing a manual restart after every boot.
  systemd.user.services.easyeffects = {
    Unit = {
      After = lib.mkForce [
        "graphical-session.target"
        "pipewire.service"
        "wireplumber.service"
        "pipewire-pulse.service"
      ];
      Wants = ["pipewire.service" "wireplumber.service" "pipewire-pulse.service"];
    };
    Service = {
      ExecStartPre = "${waitForNode} ${easyeffectsInput}";
      # Never exits on --quit/SIGTERM, so every restart sat out upstream's 10s.
      TimeoutStopSec = lib.mkForce 5;
      # DeepFilterNet underruns (RTF 5+) when builds saturate the CPU. Nice=-10
      # is not an option: user units have RLIMIT_NICE 0. Siblings in app.slice
      # (terminal scopes) default to 100.
      CPUWeight = 1000;
    };
  };

  programs.lan-mouse.enable = false;
}
