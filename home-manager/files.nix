{lib, ...}: let
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
        prefixedPath = path + ("/" + fileName);
      in
        if (type == "directory")
        then
          (
            mapRecursive prefixedPath prefixedName
          )
        else [
          {
            name = toString prefixedName;
            value = {
              source = toString prefixedPath;
            };
          }
        ]
    ) (builtins.readDir path);
in {
  home.file = builtins.listToAttrs (lib.lists.flatten (
    mapRecursive (./. + "/files") ""
  ));
}
