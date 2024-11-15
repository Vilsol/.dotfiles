{
  config,
  pkgs,
  ...
}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      open = false;
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
