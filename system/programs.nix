{
  config,
  pkgs,
  unstable,
  ...
}: {
  environment.sessionVariables = {
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  programs = {
    _1password-gui = {
      enable = true;
      package = unstable._1password-gui-beta.override {polkitPolicyOwners = ["vilsol"];};
      polkitPolicyOwners = ["vilsol"];
    };

    _1password = {
      enable = true;
      package = unstable._1password;
    };

    noisetorch = {
      enable = true;
      package = unstable.noisetorch;
    };

    firefox = {
      enable = true;
      preferences = {
        "media.hardwaremediakeys.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
      };
    };

    nix-ld.enable = true;
  };

  nix.package = pkgs.nixFlakes;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services = {
    mullvad-vpn.enable = true;
    transmission.enable = false;
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

  users.users.vilsol.extraGroups = ["docker"];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "python-2.7.18.6"
      "electron-24.8.6"
    ];

    allowUnfree = true;
    segger-jlink.acceptLicense = true;
  };
}
