let
  aagl-gtk-on-nix = import (builtins.fetchTarball {
    url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
    sha256 = "sha256:0p6rgcmcf5lxqri8f4c6hbk03dc2876b26j92nj525dfxvwqddz8";
  });
in {
  imports = [
    aagl-gtk-on-nix.module
  ];

  programs.anime-game-launcher.enable = true;
  programs.honkers-railway-launcher.enable = true;
}
