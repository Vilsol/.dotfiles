{pkgs, ...}: {
  home.packages = with pkgs; [
    appimage-run
    coreutils
    delve
    dig
    dive
    exiv2
    file
    fzf
    gdu
    glxinfo
    htop
    iptables
    jq
    kubectl
    neofetch
    nix-index
    nix-update
    nixfmt-rfc-style
    nvd
    p7zip
    unzip
    usbutils
    vulkan-tools
    xorg.xkill
  ];

  programs.btop.enable = true;
  programs.direnv.enable = true;
}
