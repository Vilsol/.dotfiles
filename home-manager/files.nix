{
  lib,
  config,
  ...
}: let
  # These are mkOutOfStoreSymlink targets, so they must be a path on the live
  # filesystem rather than in the store. The repo therefore has to live at
  # ~/.dotfiles for `files/` to resolve.
  localFlakeRoot = "${config.home.homeDirectory}/.dotfiles/home-manager";

  mapRecursive = path: prefix:
    lib.attrsets.mapAttrsToList (
      fileName: type: let
        prefixedName =
          prefix
          + (
            if prefix == ""
            then ""
            else "/"
          )
          + fileName;

        # This path is still used for reading the directory structure during build
        nixStorePath = path + ("/" + fileName);

        # This string constructs the absolute path on your filesystem
        absoluteSystemPath = "${localFlakeRoot}/files/${prefixedName}";
      in
        if (type == "directory")
        then
          (
            mapRecursive nixStorePath prefixedName
          )
        else [
          {
            name = toString prefixedName;
            value = {
              # 3. CHANGED: Use mkOutOfStoreSymlink pointing to the absolute path
              source = config.lib.file.mkOutOfStoreSymlink absoluteSystemPath;
            };
          }
        ]
    ) (builtins.readDir path);
in {
  home.file = builtins.listToAttrs (lib.lists.flatten (
    mapRecursive (./. + "/files") ""
  ));
}
