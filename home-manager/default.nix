{lib, ...}: {
  # Namespaced under `my` so it cannot collide with an upstream home-manager
  # option. Set per machine from flake.nix.
  options.my.fullDesktop = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "include all desktop software and settings";
  };

  imports = [
    ./autostart.nix
    ./dank-material-shell.nix
    ./dev.nix
    ./files.nix
    ./games.nix
    ./git.nix
    ./gtk.nix
    ./home.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./mangohud.nix
    ./programs.nix
    ./quickshell.nix
    ./social.nix
    ./ssh.nix
    ./terminal.nix
    ./tools.nix
    ./vscode.nix
    ./waybar.nix
    ./zsh.nix
  ];
}
