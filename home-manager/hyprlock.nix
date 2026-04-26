{...}: {
  programs.hyprlock = {
    enable = true;
    
    settings = {
      general = {
        disable_loading_bar = false;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 7;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
          shadow_passes = 2;
        }
      ];

      label = [
        # Time
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b><big>$(date +"%H:%M")</big></b>"'';
          color = "rgb(202, 211, 245)";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 96";
          halign = "center";
          valign = "center";
        }
        # Date
        {
          monitor = "";
          text = ''cmd[update:18000000] echo "<b>$(date +'%A, %-d %B %Y')</b>"'';
          color = "rgb(202, 211, 245)";
          font_size = 24;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
        # User
        {
          monitor = "";
          text = "$USER";
          color = "rgb(202, 211, 245)";
          font_size = 20;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}

