{
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    package = null;
    portalPackage = null;

    plugins = [
      # Disabled: hyprbars (DMS handles window decorations natively)
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
      inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system}.split-monitor-workspaces
    ];

    systemd.variables = ["--all"];

    extraConfig = ''
      require("hypr-extras")
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

      # Lock the screen — respawn on abnormal exit (e.g. SIGABRT on a wayland
      # disconnect) so a hyprlock crash self-heals instead of dropping to the
      # Hyprland fallback. Bounded to 5 tries to avoid spinning on a broken config.
      if ! pidof hyprlock > /dev/null; then
        for _ in 1 2 3 4 5; do
          ${hyprlock}/bin/hyprlock && break
          sleep 1
        done
      fi

      # Restore original border size after unlock
      ${hyprland}/bin/hyprctl keyword general:border_size "$BORDER_SIZE"
    '')

    # Wrapper for split-monitor-workspaces dispatchers under Hyprland 0.55 Lua mode.
    # `hyprctl dispatch X Y` is server-side wrapped as `hl.dispatch(X Y)` which is
    # a Lua syntax error for plugin dispatchers. We instead send an IIFE that
    # invokes the plugin's Lua API and returns a real dispatcher object.
    (writeShellScriptBin "hypr-smw" ''
      case "$1" in
        workspace)
          ${hyprland}/bin/hyprctl dispatch "(function() hl.plugin.split_monitor_workspaces.workspace(\"$2\"); return hl.dsp.exec_cmd(\"true\") end)()"
          ;;
        move-silent)
          ${hyprland}/bin/hyprctl dispatch "(function() hl.plugin.split_monitor_workspaces.move_to_workspace_silent(\"$2\"); return hl.dsp.exec_cmd(\"true\") end)()"
          ;;
        *)
          echo "Usage: hypr-smw {workspace|move-silent} <arg>" >&2
          exit 1
          ;;
      esac
    '')
  ];

  services.swaync = {
    enable = true;
  };

  imports = [
    inputs.hyprshell.homeModules.hyprshell
  ];
  programs.hyprshell = {
    enable = false;
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
