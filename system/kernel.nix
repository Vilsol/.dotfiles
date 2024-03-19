{pkgs, ...}: {
  # boot.kernelPackages = unstable.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages;
  # boot.kernelPackages = unstable.linuxPackages;

  boot.supportedFilesystems = ["ntfs"];

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";}; # Force intel-media-driver
}
