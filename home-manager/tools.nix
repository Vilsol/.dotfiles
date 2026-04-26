{pkgs, ...}: {
  home.packages = with pkgs; [
    appimage-run
    coreutils
    difftastic
    dig
    dive
    file
    fzf
    gdu
    iptables
    jq
    killall
    kubectl
    fastfetch
    nix-index
    nix-update
    nixfmt
    nvd
    p7zip
    unzip
    usbutils
    vulkan-tools
    xkill
  ];

  programs.btop.enable = true;
  programs.direnv.enable = true;
}
