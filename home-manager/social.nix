{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    unstable.element-desktop
    unstable.slack
    unstable.telegram-desktop
    unstable.zapzap
    unstable.quasselClient
    unstable.vesktop
  ];
}
