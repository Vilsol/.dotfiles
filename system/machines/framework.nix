{nixos-hardware, ...}: {
  imports = [
    nixos-hardware.nixosModules.framework-12th-gen-intel
    ../default.nix
  ];
}
