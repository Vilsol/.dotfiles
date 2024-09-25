{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      chromium
      flameshot
      fontconfig
      gimp
      dconf-editor
      gnome-tweaks
      jellyfin-media-player
      libreoffice
      pavucontrol
      remmina
      youtube-music
      vlc
      easyeffects
    ]
    ++ lib.optionals config.full-desktop [
      # gwe
      # handbrake
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      davinci-resolve
    ];
}
