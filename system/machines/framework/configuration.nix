{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    initrd = {
      secrets."/crypto_keyfile.bin" = null;
      luks.devices."luks-455789b2-0189-41a2-873a-5bbab1592592".device = "/dev/disk/by-uuid/455789b2-0189-41a2-873a-5bbab1592592";
      luks.devices."luks-455789b2-0189-41a2-873a-5bbab1592592".keyFile = "/crypto_keyfile.bin";
    };
  };

  networking.hostName = "framework";

  services = {
    xserver = {
      enable = true;
    };

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  system.stateVersion = "23.05";
}
