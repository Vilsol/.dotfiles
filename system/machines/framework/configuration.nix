{config, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd = {
      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      luks.devices."luks-455789b2-0189-41a2-873a-5bbab1592592".device = "/dev/disk/by-uuid/455789b2-0189-41a2-873a-5bbab1592592";
      luks.devices."luks-455789b2-0189-41a2-873a-5bbab1592592".keyFile = "/crypto_keyfile.bin";
    };
  };

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Riga";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "lv_LV.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "lv_LV.UTF-8";
    LC_TELEPHONE = "lv_LV.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    xserver = {
      enable = true;

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      layout = "us";
      xkbVariant = "";
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  users.users.vilsol = {
    isNormalUser = true;
    description = "vilsol";
    extraGroups = ["networkmanager" "wheel"];
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}
