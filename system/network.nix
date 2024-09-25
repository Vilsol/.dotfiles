{
  systemd.services.NetworkManager-wait-online.enable = false;

  networking = {
    # networkmanager.dns = "none";
    networkmanager.enable = true;
    firewall.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
