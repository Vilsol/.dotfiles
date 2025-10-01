{pkgs, ...}: {
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
    };

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  system.stateVersion = "23.05";

  # Keyboard
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0860", TAG+="uaccess", GROUP="dialout", MODE="0660"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess", GROUP="dialout", MODE="0660"
  '';

  services.sunshine = {
    enable = true;
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
  
  # Network configuration
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
    wifi.scanRandMacAddress = false;
  };
  
  # Kernel parameters for stability
  boot.kernelParams = [ 
    "pcie_aspm=off"
    "iwlwifi.power_save=0"  # Generic WiFi power save disable
  ];
}
