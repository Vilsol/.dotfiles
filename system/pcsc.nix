{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    pcscliteWithPolkit
  ];

  services.pcscd.enable = true;
}
