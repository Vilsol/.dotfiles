{pkgs, ...}: {
  home.packages = with pkgs; [
    libsForQt5.breeze-icons
    libsForQt5.konsole
    warp-terminal
    alacritty
    kitty
  ];
}
