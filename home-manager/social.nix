{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    unstable.discord
    unstable.discord-canary
    unstable.element-desktop
    unstable.slack
    unstable.telegram-desktop
    unstable.zapzap
  ];
}
