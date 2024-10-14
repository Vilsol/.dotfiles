{pkgs, ...}: {
  home.packages = with pkgs; [
    # element-desktop
    slack
    telegram-desktop
    zapzap
    quasselClient
    vesktop
  ];
}
