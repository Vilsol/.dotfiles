{
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.networkmanager.dns = "none";
}
