{pkgs, ...}: {
  home.packages = with pkgs; [
    warp-terminal
    alacritty
    kitty
  ];
}
