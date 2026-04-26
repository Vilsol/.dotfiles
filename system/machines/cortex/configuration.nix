{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./swap.nix
  ];

  networking.hostName = "cortex";

  services = {
    xserver = {
      enable = true;
    };

    displayManager = {
      gdm.enable = true;
      defaultSession = "hyprland-uwsm";
    };
    desktopManager.gnome.enable = true;
  };

  system.stateVersion = "23.05";

  # Keyboard & Sonoff Dongle-M
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0860", TAG+="uaccess", GROUP="dialout", MODE="0660"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess", GROUP="dialout", MODE="0660"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", TAG+="uaccess", GROUP="dialout", MODE="0660"
  '';

  services.sunshine = {
    enable = false;
    autoStart = true;
    capSysAdmin = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
    };
  };

  # Hardware support
  hardware.enableRedistributableFirmware = true;

  # WiFi driver parameters
  boot.extraModprobeConfig = ''
    # RTL8922AE WiFi 7 adapter stability
    options rtw89_core disable_ps_mode=1
    options rtw89_pci disable_aspm_l1=1 disable_aspm_l1ss=1
    options rtw89_8922a rtw89_disable_ps_mode=1
  '';

  networking.networkmanager.wifi.scanRandMacAddress = false;

  # Kernel parameters for stability
  boot.kernelParams = [
    "pcie_aspm=off"
    "iwlwifi.power_save=0" # Generic WiFi power save disable
  ];

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  environment.systemPackages = [
    pkgs.fprintd
  ];
}
