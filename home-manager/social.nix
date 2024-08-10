{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    element-desktop
    slack
    telegram-desktop
    zapzap
    quasselClient
    unstable.vesktop
  ];
}
