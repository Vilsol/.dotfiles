{
  lib,
  pkgs,
  config,
  ...
}: let
  autostartPrograms =
    [
      pkgs._1password-gui-beta
    ]
    ++ lib.optionals config.full-desktop [
      pkgs.input-leap
      pkgs.jetbrains-toolbox
      pkgs.slack
      pkgs.telegram-desktop
      pkgs.vesktop
    ];
in {
  home.file = builtins.listToAttrs (map
    (pkg: {
      name = ".config/autostart/" + pkg.pname + ".desktop";
      value =
        if pkg ? desktopItem
        then {
          # Application has a desktopItem entry.
          # Assume that it was made with makeDesktopEntry, which exposes a
          # text attribute with the contents of the .desktop file
          inherit (pkg.desktopItem) text;
        }
        else {
          # Application does *not* have a desktopItem entry. Try to find a
          # matching .desktop name in /share/applications
          source =
            pkg
            + "/share/applications/"
            + (
              lib.lists.findFirst (name: (lib.strings.hasSuffix ".desktop" name)) "NULL" (
                lib.attrsets.mapAttrsToList (name: _: name) (
                  builtins.readDir (pkg + "/share/applications/")
                )
              )
            );
        };
    })
    autostartPrograms);
}
