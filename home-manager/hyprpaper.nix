_: {
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";

      splash = false;

      preload = [
        "~/.background-image.png"
      ];

      wallpaper = [
        "DP-3,~/.background-image.png"
        "DP-2,~/.background-image.png"
      ];
    };
  };
}
