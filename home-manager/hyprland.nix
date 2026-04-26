{
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;

    package = null;
    portalPackage = null;

    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
      inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
    ];

    systemd.variables = ["--all"];

    extraConfig = ''
      source = ~/.config/hypr/hypr-extras.conf
    '';
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.packages = with pkgs; [
    wofi
    swappy
    wl-clipboard
    grim
    slurp
    waybar-mpris
    # Lock screen script that handles border hiding/restoring
    (writeShellScriptBin "lock-screen" ''
      # Read current border size
      BORDER_SIZE=$(${hyprland}/bin/hyprctl getoption general:border_size -j | ${pkgs.jq}/bin/jq -r '.int')

      # Hide borders before locking
      ${hyprland}/bin/hyprctl keyword general:border_size 0
      sleep 0.01

      # Lock the screen
      pidof hyprlock || ${hyprlock}/bin/hyprlock

      # Restore original border size after unlock
      ${hyprland}/bin/hyprctl keyword general:border_size "$BORDER_SIZE"
    '')
  ];

  services.swaync = {
    enable = true;
  };

  imports = [
    inputs.hyprshell.homeModules.hyprshell
  ];
  programs.hyprshell = {
    enable = true;
    systemd.args = "-v";
    settings = {
      windows = {
        enable = true;
        overview = {
          enable = true;
          key = "super_l";
          modifier = "super";
          launcher = {
            max_items = 6;
          };
        };
        switch = {
          enable = true;
          modifier = "alt";
          filter_by = [];
        };
      };
    };
  };
}
