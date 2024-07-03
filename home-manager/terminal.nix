{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    libsForQt5.breeze-icons
    libsForQt5.konsole
    unstable.warp-terminal
    unstable.alacritty
    unstable.kitty
  ];
}
