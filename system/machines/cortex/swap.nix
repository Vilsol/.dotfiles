{lib, ...}: {
  swapDevices = lib.mkForce [
    {
      device = "/dev/disk/by-partuuid/3045410d-85ec-1946-a9d9-fec1bc04254f";
      randomEncryption = {
        enable = true;
        cipher = "aes-xts-plain64";
      };
      priority = 10;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
