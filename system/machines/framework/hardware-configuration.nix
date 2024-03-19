{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
      kernelModules = [];

      luks.devices."luks-6af03e0b-8d58-4b2f-940b-26a579cfc234".device = "/dev/disk/by-uuid/6af03e0b-8d58-4b2f-940b-26a579cfc234";
    };

    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c780fb83-58f8-4094-9598-5821631177cf";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9089-5DF9";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/0d493bd8-b73a-4e2f-a42a-dd5764b181d1";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
