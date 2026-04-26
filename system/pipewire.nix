{pkgs, ...}: {
  services.pipewire.jack.enable = true;

  environment.systemPackages = with pkgs; [
    adwaita-qt
  ];
}
