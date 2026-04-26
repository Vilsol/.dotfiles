{...}: {
  services.hypridle = {
    enable = true;
    
    settings = {
      general = {
        lock_cmd = "lock-screen";  # Use wrapper script that handles borders
        before_sleep_cmd = "lock-screen";  # Lock before suspend
        after_sleep_cmd = "hyprctl dispatch dpms on";  # Turn displays on after suspend
      };

      listener = [
        # Lock screen after 30 minutes
        {
          timeout = 1800;
          on-timeout = "lock-screen";
        }
        # Turn off displays after 35 minutes
        {
          timeout = 2100;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}

