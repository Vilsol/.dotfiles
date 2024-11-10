{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  hardware.steam-hardware.enable = true;

  environment.sessionVariables.MANGOHUD = "1";

  programs.gamescope.enable = true;
}
