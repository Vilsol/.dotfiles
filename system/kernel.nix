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
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
