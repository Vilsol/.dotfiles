{
  config,
  pkgs,
  ...
}: {
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

      luks.devices."luks-1b641a1e-4ee4-47f6-8298-6255c9a68ac7".device = "/dev/disk/by-uuid/1b641a1e-4ee4-47f6-8298-6255c9a68ac7";
      luks.devices."luks-1b641a1e-4ee4-47f6-8298-6255c9a68ac7".keyFile = "/crypto_keyfile.bin";
    };
  };

  networking = {
    hostName = "cortex";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  time.timeZone = "Europe/Riga";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "lv_LV.UTF-8";
    LC_IDENTIFICATION = "lv_LV.UTF-8";
    LC_MEASUREMENT = "lv_LV.UTF-8";
    LC_MONETARY = "lv_LV.UTF-8";
    LC_NAME = "lv_LV.UTF-8";
    LC_NUMERIC = "lv_LV.UTF-8";
    LC_PAPER = "lv_LV.UTF-8";
    LC_TELEPHONE = "lv_LV.UTF-8";
    LC_TIME = "lv_LV.UTF-8";
  };

  services = {
    xserver = {
      enable = true;

      displayManager = {
        gdm.enable = true;

        autoLogin.enable = true;
        autoLogin.user = "vilsol";
      };
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
    description = "Vilsol";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      firefox
    ];
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables.MANGOHUD = "1";

  system.stateVersion = "23.05";
}
