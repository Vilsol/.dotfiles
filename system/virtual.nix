{pkgs, ...}:

let
  enabled = false;
in {
  users.extraGroups.vboxusers.members = ["vilsol"];
  virtualisation.virtualbox = {
    host = {
      enable = enabled;
      enableExtensionPack = enabled;
    };
    guest = {
      enable = enabled;
      dragAndDrop = enabled;
      clipboard = enabled;
    };
  };

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["vilsol"];

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };
}
