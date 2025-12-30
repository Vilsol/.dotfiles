{inputs, pkgs, ...}: {
  imports = [inputs.hyprland.nixosModules.default];

  programs.hyprland = {
    enable = true;
    withUWSM = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    ];
  };

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;
  programs.uwsm.enable = true;
}
