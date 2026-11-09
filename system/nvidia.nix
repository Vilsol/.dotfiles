{
  config,
  lib,
  pkgs,
  ...
}: let
  # Nyx builds its driver with patchelf 0.19, which leaves DYNAMIC in a
  # read-only segment of the non-PIE binaries; ld.so segfaults writing
  # DT_DEBUG. Repatch the untouched origBin copies with 0.15 instead.
  patchelf_0_15 = pkgs.patchelf.overrideAttrs {
    version = "0.15.2";
    src = pkgs.fetchurl {
      url = "https://github.com/NixOS/patchelf/releases/download/0.15.2/patchelf-0.15.2.tar.bz2";
      hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
    };
  };
  nvidiaBin = config.hardware.nvidia.package.bin;
  nvidiaBinFixed = pkgs.runCommand "nvidia-bin-fixed" {} ''
    mkdir -p $out/bin
    for i in nvidia-smi nvidia-cuda-mps-control nvidia-powerd; do
      install -m755 ${nvidiaBin}/origBin/$i $out/bin/$i
      ${patchelf_0_15}/bin/patchelf \
        --set-interpreter "$(${patchelf_0_15}/bin/patchelf --print-interpreter ${nvidiaBin}/bin/$i)" \
        --set-rpath "$(${patchelf_0_15}/bin/patchelf --print-rpath ${nvidiaBin}/bin/$i)" \
        $out/bin/$i
    done
  '';
in {
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    graphics.enable = true;
    nvidia = {
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      # Nyx's driver for its kernel (cached on nyx-cache). Building nvidia-x11
      # ourselves against the znver4 kernelPackages drags nvidia-settings'
      # deps through the znver4 package set, where cups is marked broken.
      package = config.boot.kernelPackages.nvidiaPackages.cachyos;
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
    (lib.hiPrio nvidiaBinFixed)
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
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 225";
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
