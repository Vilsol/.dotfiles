{
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
      xkb.layout = "us";
      xkb.variant = "";
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  users.users.vilsol = {
    isNormalUser = true;
    description = "Vilsol";
    extraGroups = ["networkmanager" "wheel"];
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

  services.fwupd.enable = true;

  nix.settings.trusted-users = ["vilsol"];
}
