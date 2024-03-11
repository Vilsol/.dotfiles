{pkgs, ...}: {
  home.packages = with pkgs; [
    coreutils
    nvd
    vulkan-tools
    glxinfo
    fzf
    neofetch
    jq
    appimage-run
    file
    sqlite-web
    nixfmt
    htop
    p7zip
    kubectl
    dig
    exiv2
    dive
    usbutils
    xorg.xkill
    delve
    unzip
    backblaze-b2
    iptables
    gdu
    distrobox
    vault
    consul
    nix-index
    nix-update
    nix-output-monitor
  ];

  programs.btop.enable = true;
  programs.direnv.enable = true;
}
