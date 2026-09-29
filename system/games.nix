{pkgs, ...}: let
  vrcompositorLauncher = "/home/vilsol/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
in {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # Force Steam to use proper DPI scaling on high-DPI displays
    extraCompatPackages = [];
    gamescopeSession.enable = true;
  };

  hardware.steam-hardware.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  # Environment variables for Steam scaling on Wayland
  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "2";
  };

  # SteamVR wants cap_sys_nice on vrcompositor-launcher and tries to set it via
  # pkexec, which isn't setuid inside Steam's FHS env, so it fails and nags on
  # every launch. Set it from the host instead, and again after each SteamVR
  # update replaces the binary.
  systemd.services.steamvr-setcap = {
    description = "Grant cap_sys_nice to SteamVR's vrcompositor-launcher";
    wantedBy = ["multi-user.target"];
    unitConfig.ConditionPathExists = vrcompositorLauncher;
    serviceConfig.Type = "oneshot";
    path = [pkgs.libcap];
    script = ''
      getcap ${vrcompositorLauncher} | grep -q cap_sys_nice \
        || setcap CAP_SYS_NICE+ep ${vrcompositorLauncher}
    '';
  };

  systemd.paths.steamvr-setcap = {
    wantedBy = ["multi-user.target"];
    pathConfig.PathChanged = vrcompositorLauncher;
  };
}
