{...}: {
  programs.waybar = {
    enable = true;
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
          on-scroll-up = "hyprctl dispatch split-workspace r-1";
          on-scroll-down = "hyprctl dispatch split-workspace r+1";
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

