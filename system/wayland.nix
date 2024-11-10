{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # This breaks too much shit right now
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
