{
  pkgs,
  inputs,
  ...
}: {
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = "firefox-nightly-bin\n";
    mode = "0755";
  };

  programs = {
    _1password-gui = {
      enable = true;
      # package = pkgs._1password-gui-beta.override {polkitPolicyOwners = ["vilsol"];};
      # On Wayland the fixed-size prompts get sized unscaled while content is
      # drawn at text-scaling-factor, cropping them. X11 scales both.
      # Wraps the share/ binary since 1Password-BrowserSupport execs it directly.
      package = pkgs._1password-gui.overrideAttrs (old: {
        postFixup =
          (old.postFixup or "")
          + ''
            wrapProgram $out/share/1password/1password --add-flags "--ozone-platform=x11 --force-device-scale-factor=1.5"
          '';
      });
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

  # pkgs.lix (2.95) fails to build: nixpkgs passes -Dmimalloc, which only
  # exists from 2.96. Revert to pkgs.lix once it points at 2.96+.
  nix.package = pkgs.lixPackageSets.lix_2_96.lix;
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
