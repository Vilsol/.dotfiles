{pkgs, ...}: let
  enabled = false;
in {
  users.extraGroups.vboxusers.members = ["vilsol"];
  users.groups.libvirtd.members = ["vilsol"];

  programs.virt-manager.enable = true;

  virtualisation = {
    virtualbox = {
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

    spiceUSBRedirection.enable = true;

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };
}
