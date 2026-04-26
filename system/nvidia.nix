{pkgs, ...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    graphics.enable = true;
    nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      open = true;

      # package =
      #   let
      #       base = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #           version = "590.48.01";
      #           sha256_64bit = "sha256-ueL4BpN4FDHMh/TNKRCeEz3Oy1ClDWto1LO/LWlr1ok=";
      #           openSha256 = "sha256-hECHfguzwduEfPo5pCDjWE/MjtRDhINVr4b1awFdP44=";
      #           settingsSha256 = "sha256-4SfCWp3swUp+x+4cuIZ7SA5H7/NoizqgPJ6S9fm90fA=";
      #           persistencedSha256 = "";
      #       };
      #       cachyos-nvidia-patch = pkgs.fetchpatch {
      #           url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
      #           sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
      #       };

      #       # Patch the appropriate driver based on config.hardware.nvidia.open
      #       driverAttr = if config.hardware.nvidia.open then "open" else "bin";
      #   in
      #   base
      #   // {
      #       ${driverAttr} = base.${driverAttr}.overrideAttrs (oldAttrs: {
      #           patches = (oldAttrs.patches or [ ]) ++ [ cachyos-nvidia-patch ];
      #       });
      #   };
    };
    nvidia-container-toolkit.enable = true;
  };

  environment.systemPackages = [
    pkgs.nvidia-vaapi-driver
  ];

  systemd.timers."nvidia-tdp" = {
    enable = true;
    unitConfig = {
      Description = "Set NVIDIA power limit on boot";
    };
    timerConfig = {
      OnBootSec = 5;
    };
    wantedBy = ["timers.target"];
  };

  systemd.services."nvidia-tdp" = {
    enable = true;
    unitConfig = {
      Description = "Set NVIDIA power limit";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "/run/current-system/sw/bin/nvidia-smi -pm 1";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 200";
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    WEBKIT_DISABLE_DMABUF_RENDERER = "1";
  };

  services.xserver = {
    deviceSection = ''
      Option "Coolbits" "12"
    '';
  };
}
