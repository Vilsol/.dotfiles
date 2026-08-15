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
      #
      # split-monitor-workspaces is no longer a C++ plugin. Upstream gutted it to
      # a stub that only logs a deprecation notice (registering no dispatchers and
      # no hl.plugin API) and reshipped the functionality as a Lua package, which
      # hypr-extras.lua requires off the package.path set below.
    ];

    # uwsm owns graphical-session.target, so HM's duplicate session integration
    # must stay off. It generates hyprland-session.target plus a hyprland.start
    # hook that bounces it; since HM gained PropagatesStopTo=graphical-session.target
    # that stop cascades through wayland-session@ -> wayland-wm@ and kills the
    # compositor ~1s into every login. uwsm finalize already does the
    # dbus-update-activation-environment/import-environment work this replaced.
    systemd.enable = false;

    extraConfig = ''
      package.path = package.path .. ";${inputs.split-monitor-workspaces}/lua/?.lua"
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

    # Wrapper for split-monitor-workspaces dispatchers under Hyprland Lua mode.
    # `hyprctl dispatch X Y` is server-side wrapped as `hl.dispatch(X Y)` which is
    # a Lua syntax error, so we still send an IIFE. require() hits package.loaded
    # (the module is already loaded by hypr-extras.lua off the package.path set
    # above), and the Lua package returns real dispatchers, so we return directly
    # instead of the old exec_cmd("true") stand-in the C++ API needed.
    (writeShellScriptBin "hypr-smw" ''
      case "$1" in
        workspace)
          ${hyprland}/bin/hyprctl dispatch "(function() return require(\"split-monitor-workspaces\").workspace(\"$2\") end)()"
          ;;
        move-silent)
          ${hyprland}/bin/hyprctl dispatch "(function() return require(\"split-monitor-workspaces\").move_to_workspace_silent(\"$2\") end)()"
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
