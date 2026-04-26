{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [inputs.lan-mouse.homeManagerModules.default];

  home.packages = with pkgs;
    [
      # chromium
      fontconfig
      gimp
      dconf-editor
      gnome-tweaks
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
    ]
    ++ lib.optionals config.full-desktop [
      # gwe
      # handbrake
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      # davinci-resolve
    ];

  services.easyeffects.enable = true;

  # programs.lan-mouse = {
  #   enable = true;
  # };
}
