{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    libsForQt5.konsole
    libsForQt5.breeze-icons
    unstable.warp-terminal
  ];
}
