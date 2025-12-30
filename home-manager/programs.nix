{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      # chromium
      fontconfig
      gimp
      dconf-editor
      gnome-tweaks
      # jellyfin-media-player
      libreoffice
      pavucontrol
      remmina
      vlc
      easyeffects
      spotify
      deskflow
      obsidian
    ]
    ++ lib.optionals config.full-desktop [
      # gwe
      # handbrake
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      # davinci-resolve
    ];
}
