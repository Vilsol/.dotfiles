{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      # Force Steam to use proper DPI scaling on high-DPI displays
      extraCompatPackages = [];
      gamescopeSession.enable = true;
    };

    # Launch a game with `gamemoderun %command%`; its start/end hooks cap claude.slice (home-manager/claude-cap.nix).
    gamemode.enable = true;

    gamescope = {
      enable = true;
      capSysNice = false;
    };
  };

  hardware.steam-hardware.enable = true;

  # Environment variables for Steam scaling on Wayland
  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "2";
  };
}
