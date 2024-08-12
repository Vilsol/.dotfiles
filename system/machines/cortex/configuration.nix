{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    initrd = {
      secrets."/crypto_keyfile.bin" = null;
      luks.devices."luks-1b641a1e-4ee4-47f6-8298-6255c9a68ac7".device = "/dev/disk/by-uuid/1b641a1e-4ee4-47f6-8298-6255c9a68ac7";
      luks.devices."luks-1b641a1e-4ee4-47f6-8298-6255c9a68ac7".keyFile = "/crypto_keyfile.bin";
    };
  };

  networking.hostName = "cortex";

  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  system.stateVersion = "23.05";
}
