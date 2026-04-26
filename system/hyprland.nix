{inputs, pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Override uwsm session file to remove TryExec that GDM can't validate
  services.displayManager.sessionPackages = [
    (pkgs.runCommand "hyprland-uwsm-session" {
      passthru.providedSessions = [ "hyprland-uwsm" ];
    } ''
      mkdir -p $out/share/wayland-sessions
      cat > $out/share/wayland-sessions/hyprland-uwsm.desktop << EOF
      [Desktop Entry]
      Name=Hyprland (uwsm)
      Comment=An intelligent dynamic tiling Wayland compositor managed by uwsm
      Exec=${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop
      Type=Application
      DesktopNames=Hyprland
      EOF
    '')
  ];
}
