{lib, ...}: {
  home.activation.copySSHConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD cp ~/.ssh/config_link ~/.ssh/config
    $DRY_RUN_CMD chmod 600 ~/.ssh/config
  '';
}
