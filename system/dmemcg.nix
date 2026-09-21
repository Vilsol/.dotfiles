# VRAM eviction protection for the focused app, via the dmem cgroup controller.
# dmemcg-booster enables dmem down the systemd tree (the system instance up to
# user@<uid>.service, the user instance inside it) and gives app.slice the full
# dmem.low; hyprland-focused-booster then moves that protection to whichever
# app scope owns the focused window. Needs a driver that registers a region in
# /sys/fs/cgroup/dmem.capacity (nvidia >= 615) and apps in their own scopes (uwsm).
{pkgs, ...}: let
  dmemcg-booster = pkgs.rustPlatform.buildRustPackage rec {
    pname = "dmemcg-booster";
    version = "0.1.3";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.steamos.cloud";
      owner = "holo";
      repo = "dmemcg-booster";
      tag = version;
      hash = "sha256-JDT+JKxgaETinIHiP0Pqb7fPNrvcI6AQu90nmoA/YuI=";
    };
    cargoHash = "sha256-NHK4734Jvi4RJieGn0RjYU0PzQFqaE4exHG77dmukig=";
    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.dbus];
  };

  hyprland-focused-booster = pkgs.rustPlatform.buildRustPackage rec {
    pname = "hyprland-focused-booster";
    version = "0.1.6";
    src = pkgs.fetchFromGitHub {
      owner = "tumrin";
      repo = "hyprland-focused-booster";
      tag = version;
      hash = "sha256-CrGSE3R9d4MQ6INWC33NT496WGzaByf7oZmdIQSHFSo=";
    };
    cargoHash = "sha256-aFV9uzcp9XCLD5zzfLBt5ypJ9LsvqcuIDuuMr2c38Vc=";
    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.systemd];
  };
in {
  systemd = {
    services.dmemcg-booster-system = {
      description = "Enable dmem cgroup protection, system level";
      wantedBy = ["multi-user.target"];
      serviceConfig.ExecStart = "${dmemcg-booster}/bin/dmemcg-booster --use-system-bus";
    };

    user.services.dmemcg-booster-user = {
      description = "Enable dmem cgroup protection, user level";
      wantedBy = ["graphical-session-pre.target"];
      serviceConfig.ExecStart = "${dmemcg-booster}/bin/dmemcg-booster";
    };

    user.services.hyprland-focused-booster = {
      description = "Give the focused Hyprland app VRAM priority";
      after = ["dmemcg-booster-user.service" "graphical-session.target"];
      partOf = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      # GDM also offers GNOME; there is no Hyprland socket to listen on there.
      unitConfig.ConditionEnvironment = "HYPRLAND_INSTANCE_SIGNATURE";
      serviceConfig = {
        ExecStart = "${hyprland-focused-booster}/bin/hyprland-focused-booster";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
