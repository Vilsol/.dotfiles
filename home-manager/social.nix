{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    unstable.telegram-desktop
    unstable.slack
    unstable.discord-canary
    unstable.discord
    unstable.zapzap
    unstable.element-desktop
  ];
}
