{
  pkgs,
  unstable,
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
      gnome.dconf-editor
      gnome.gnome-tweaks
      jellyfin-media-player
      libreoffice
      pavucontrol
      remmina
      unstable.youtube-music
      vlc
      easyeffects
    ]
    ++ lib.optionals config.full-desktop [
      gwe
      handbrake
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      unstable.davinci-resolve
    ];
}
