{
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

    # Enable background system updates
    # nixos-background-updates = {
    #   enable = true;
    #   time = "05:00";  # Run at 5 AM
    #   randomizedDelay = "30min";  # Add up to 30 min random delay
    # };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  users.users.vilsol = {
    isNormalUser = true;
    description = "Vilsol";
    extraGroups = ["networkmanager" "wheel" "ydotool" "uinput"];
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;

  services.fwupd.enable = true;

  nix.settings.trusted-users = ["vilsol"];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "1048576";
  };

  programs.ydotool.enable = true;
}
