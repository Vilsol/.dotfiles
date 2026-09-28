{
  pkgs,
  inputs,
  ...
}: {
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs = {
    _1password-gui = {
      enable = true;
      # package = pkgs._1password-gui-beta.override {polkitPolicyOwners = ["vilsol"];};
      polkitPolicyOwners = ["vilsol"];
    };

    _1password = {
      enable = true;
      package = pkgs._1password-cli;
    };

    firefox = {
      package = inputs.firefox-nightly.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
      enable = true;
      preferences = {
        "media.hardwaremediakeys.enabled" = false;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "gfx.x11-egl.force-enabled" = true;
        "apz.gtk.kinetic_scroll.enabled" = false;
      };
    };

    nix-ld.enable = true;
  };

  nix.package = pkgs.lix;
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

  programs.coolercontrol = {
    enable = true;
  };

  programs.kdeconnect = {
    enable = false;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  # Pulls in hardware.logitech.wireless.enable itself.
  programs.solaar.enable = true;
}
