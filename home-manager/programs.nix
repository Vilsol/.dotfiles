{
  pkgs,
  unstable,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs;
    [
      gnome.dconf-editor
      gnome.gnome-tweaks
      unstable.youtube-music
      mullvad-vpn
      transmission-remote-gtk
      gimp
      wireshark
      remmina
      chromium
      flameshot
      easyeffects
      libreoffice
      unstable.obsidian
      fontconfig
      jellyfin-media-player
      pavucontrol
      wineWowPackages.stable
    ]
    ++ lib.optionals config.full-desktop [
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      kdenlive
      unstable.davinci-resolve
      handbrake
      gwe
    ];
}
