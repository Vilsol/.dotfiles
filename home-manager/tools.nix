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

  programs.btop = {
    enable = true;
    # Only adds /run/opengl-driver/lib to RUNPATH so btop can dlopen NVML.
    package = pkgs.btop.override {cudaSupport = true;};
  };
  programs.direnv.enable = true;
}
