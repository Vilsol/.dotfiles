{
  nix = {
    optimise.automatic = true;

    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  boot = {
    plymouth = {
      enable = true;
      theme = "breeze";
    };
    kernelParams = ["quiet" "udev.log_level=3"];
  };
}
