{config, ...}: {
  home = {
    username = "vilsol";
    homeDirectory = "/home/vilsol";

    stateVersion = "23.05";

    sessionVariables = {
      EDITOR = "nano";
    };
  };

  programs.home-manager.enable = true;

  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"; 
}
