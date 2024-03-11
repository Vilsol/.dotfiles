{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    gnome.dconf-editor
    gnome.gnome-tweaks
    unstable.youtube-music
    # gwe
    mullvad-vpn
    transmission-remote-gtk
    gimp
    wireshark
    remmina
    chromium
    flameshot
    easyeffects
    kdenlive
    libreoffice
    handbrake
    unstable.obsidian
    fontconfig
    jellyfin-media-player
    pavucontrol
    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture
    wineWowPackages.stable
  ];
}
