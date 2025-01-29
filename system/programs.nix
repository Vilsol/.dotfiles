{
  pkgs,
  config,
  androidComposition,
  ...
}: {
  environment.sessionVariables = {
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  programs = {
    _1password-gui = {
      enable = true;
      package = pkgs._1password-gui-beta.override {polkitPolicyOwners = ["vilsol"];};
      polkitPolicyOwners = ["vilsol"];
    };

    _1password = {
      enable = true;
      package = pkgs._1password-cli;
    };

    firefox = {
      enable = true;
      preferences = {
        "media.hardwaremediakeys.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "apz.gtk.kinetic_scroll.enabled" = false;
      };
    };

    nix-ld.enable = true;
  };

  nix.package = pkgs.nixVersions.stable;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services = {
    tailscale.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
  };

  virtualisation.docker = {
    enable = true;
  };

  environment.systemPackages = with pkgs;
    lib.optionals config.full-desktop [
      flutter
      android-tools
      (androidStudioPackages.beta.full.withSdk androidComposition.androidsdk)
    ];
  programs.adb.enable = true;
  users.users.vilsol.extraGroups = [
    "docker"
    "adbusers"
    "dialout"
  ];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "python-2.7.18.6"
      "electron-24.8.6"
    ];

    allowUnfree = true;
    segger-jlink.acceptLicense = true;
  };

  programs.coolercontrol = {
    enable = true;
  };
}
