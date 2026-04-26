{...}: {
  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
        QT_SCALE_FACTOR = "1.5";
      };
    };
    settings = {
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      font = {
        normal = {
          size = 12;
        };
      };
    };
  };
}

