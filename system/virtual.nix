let
  enabled = false;
in {
  users.extraGroups.vboxusers.members = ["vilsol"];
  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox = {
    host = {
      enable = enabled;
      enableExtensionPack = enabled;
    };
    guest = {
      enable = enabled;
      dragAndDrop = enabled;
      clipboard = enabled;
    };
  };
}
