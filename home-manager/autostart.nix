{
  lib,
  pkgs,
  config,
  ...
}: let
  # The .desktop file name is spelled out instead of discovered with readDir:
  # reading share/applications forces the package to be realised during
  # evaluation, so any version bump that is not built yet aborts the whole
  # rebuild.
  autostartPrograms =
    [
      {
        package = pkgs._1password-gui;
        desktopFile = "1password.desktop";
      }
    ]
    ++ lib.optionals config.my.fullDesktop [
      {
        package = pkgs.telegram-desktop;
        desktopFile = "org.telegram.desktop.desktop";
      }
      {
        package = pkgs.discord;
        desktopFile = "discord.desktop";
      }
    ];
in {
  home.file = builtins.listToAttrs (map
    ({
      package,
      desktopFile,
    }: {
      name = ".config/autostart/${package.pname}.desktop";
      value.source = "${package}/share/applications/${desktopFile}";
    })
    autostartPrograms);
}
