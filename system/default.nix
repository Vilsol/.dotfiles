{lib, ...}: {
  imports = [
    ./ai.nix
    ./cachix.nix
    ./common.nix
    # ./flatpak.nix
    ./fonts.nix
    ./games.nix
    ./kernel.nix
    ./minikube.nix
    ./network.nix
    ./os.nix
    ./pcsc.nix
    ./pipewire.nix
    ./programs.nix
    ./shell.nix
    ./virtual.nix
    ./wayland.nix
  ];

  options = {
    full-desktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "include all desktop software and settings";
    };
  };
}
