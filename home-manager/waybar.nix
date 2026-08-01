{pkgs, ...}: {
  programs.waybar = {
    enable = false;

    # Pin to upstream master for Hyprland 0.55 Lua-mode workspace click fix
    # (Alexays/Waybar PR #5013, merged 2026-05-04, post-0.15.0).
    # cavaSupport is disabled because master's cava subproject layout doesn't
    # match the version nixpkgs vendors in postUnpack. You don't use the cava
    # module anyway; re-enable here if you ever add it.
    # Drop this whole override once a release including #5013 is in nixpkgs.
    package = (pkgs.waybar.override {cavaSupport = false;}).overrideAttrs (_old: {
      version = "0.15.0-unstable-2026-05-04";
      src = pkgs.fetchFromGitHub {
        owner = "Alexays";
        repo = "Waybar";
        rev = "05945748dccce28bf96d26d8f64a9e69a8dd49ba";
        hash = "sha256-51R3mIt8cLNvh/X5qe9vOqeJCj0U9KRyemVE5y+OhiU=";
      };
      # waybar's binary still self-reports 0.15.0 (master didn't bump version
      # string), but our `version` attr includes the unstable date suffix.
      # nixpkgs' versionCheckPhase compares the two and fails.
      doInstallCheck = false;
    });

    systemd = {
      enable = true;
      targets = ["hyprland-session.target"];
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 50;
        output = ["DP-3" "DP-2"];

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
          "mpris"
        ];
        modules-center = [
          "clock"
          "tray"
        ];
        modules-right = [
          "hyprland/language"
          "pulseaudio"
          "custom/notification"
        ];

        "hyprland/workspaces" = {
          format = "{icon} {windows}";
          "window-rewrite-default" = "";
          format-icons = {
            urgent = "";
            active = "";
            visible = "";
            default = "";
            empty = "";
          };
          "window-rewrite" = {
            "title<.*youtube.*>" = "";
            "class<firefox>" = "";
            "class<firefox> title<.*github.*>" = "";
            "foot" = "";
            "code" = "󰨞";
          };
          "workspace-taskbar" = {
            "enable" = true;
            "update-active-window" = true;
            "format" = "{icon}";
          };
          all-outputs = false;
          # Per-workspace-button clicks are handled by waybar's patched
          # IPC::dispatch (PR #5013) — module-level on-click only fires for
          # empty module space, so configuring it doesn't help.
          # Scroll handlers stay overridden because hypr-smw uses the plugin's
          # per-monitor relative dispatcher ("r-1"/"r+1"), which is more
          # accurate for the split-monitor-workspaces setup than waybar's
          # built-in "m-1"/"m+1" path.
          on-scroll-up = "hypr-smw workspace r-1";
          on-scroll-down = "hypr-smw workspace r+1";
        };

        "hyprland/window" = {
          max-length = 50;
        };

        "mpris" = {
          interval = 1;
          format = "{player_icon} {dynamic}";
          format-paused = "{status_icon} {artist}";
          on-click-middle = "playerctl play-pause";
          on-click = "playerctl previous";
          on-click-right = "playerctl next";
          scroll-step = 5.0;
          smooth-scrolling-threshold = 1;
          tooltip = true;
          tooltip-format = "{status_icon} {title}\nLeft Click: previous\nMid Click: Pause\nRight Click: Next";
          player-icons = {
            default = "";
            firefox = "";
            spotify = "󰎆";
            vlc = "󰕼";
          };
          status-icons = {
            paused = "";
            playing = "";
            stopped = "";
          };
          dynamic-order = ["artist"];
          max-length = 25;
        };

        clock = {
          format = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
          };
        };

        "hyprland/language" = {
          "format" = "{}";
          "format-en" = "US";
          "format-lv" = "LV";
          on-click = "hyprctl switchxkblayout all next";
        };

        # Integration with SwayNC
        "custom/notification" = {
          tooltip = true;
          format = "<span size='14pt'>{icon}</span>";
          format-icons = {
            notification = "󱅫";
            none = "󰂜";
            dnd-notification = "󰂠";
            dnd-none = "󰪓";
            inhibited-notification = "󰂛";
            inhibited-none = "󰪑";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰪑";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        network = {
          format-ethernet = "{ifname} ";
          format-disconnected = "Disconnected ⚠";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" ""];
          };
          on-click = "pavucontrol";
        };

        cpu = {
          format = "{usage}% ";
        };

        memory = {
          format = "{}% ";
        };

        tray = {
          spacing = 10;
        };
      };
    };
  };
}
