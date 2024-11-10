{pkgs, ...}: {
  home.packages = with pkgs; [
    gnome-themes-extra
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.always-show-titles-in-overview
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.grand-theft-focus
    gnomeExtensions.no-overview
    gnomeExtensions.openweather-refined
    gnomeExtensions.removable-drive-menu
    gnomeExtensions.tailscale-status
    gnomeExtensions.wireless-hid
  ];

  dconf.settings = {
    "org/gnome/desktop/background" = {
      "picture-uri" = "file:///home/vilsol/.background-image.png";
      "picture-uri-dark" = "file:///home/vilsol/.background-image.png";
    };
    "org/gnome/desktop/screensaver" = {
      "picture-uri" = "file:///home/vilsol/.background-image.png";
      "picture-uri-dark" = "file:///home/vilsol/.background-image.png";
    };
    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = "appmenu:minimize,maximize,close";
    };
    "org/gnome/desktop/interface" = {
      "clock-show-seconds" = true;
      "clock-show-weekday" = true;
      "gtk-theme" = "Adwaita-dark";
      "enable-hot-corners" = false;
      "color-scheme" = "prefer-dark";
      "show-battery-percentage" = true;
      "cursor-size" = 32;
      "text-scaling-factor" = 1.5;
    };
    "org/gnome/desktop/search-providers" = {
      "disabled" = ["org.gnome.Characters.desktop"];
    };
    "org/gnome/shell" = {
      "favorite-apps" = ["firefox.desktop" "org.gnome.Nautilus.desktop"];
      "disable-user-extensions" = false;
      "enabled-extensions" = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "advanced-alt-tab@G-dH.github.com"
        "Always-Show-Titles-In-Overview@gmail.com"
        "wireless-hid@chlumskyvaclav.gmail.com"
        "tailscale-status@maxgallup.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "openweather-extension@jenslody.de"
        "no-overview@fthx"
        "blur-my-shell@aunetx"
        "grand-theft-focus@zalckos.github.com"
      ];
    };
    "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
      "enable-super" = true;
      "hot-edge-position" = 0;
      "switcher-popup-monitor" = 3;
      "switcher-popup-position" = 2;
      "switcher-popup-start-search" = false;
      "switcher-popup-timeout" = 10;
      "switcher-popup-tooltip-label-scale" = 150;
      "win-switcher-popup-filter" = 1;
      "win-switcher-popup-preview-size" = 296;
      "win-switcher-popup-ws-indexes" = false;
      "win-switcher-single-prev-size" = 224;
      "win-switch-include-modals" = true;
    };
    "org/gnome/desktop/wm/keybindings" = {
      "switch-applications" = [];
      "switch-applications-backward" = [];
      "switch-windows" = ["<Alt>Tab"];
      "switch-windows-backward" = ["<Shift><Alt>Tab"];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      "binding" = "<Shift><Alt>t";
      # "command" = "bash -c 'konsole --new-tab && wmctrl -a \"Konsole\"'";
      # "name" = "Konsole";
      "command" = "bash -c 'xdg-open warp://action/new_tab?path=~ && wmctrl -a \"vilsol@\"'";
      "name" = "Warp";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      "custom-keybindings" = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };
    "org/gnome/shell/extensions/openweather" = {
      "city" = "56.9493977,24.1051846>Rīga, Vidzeme, Latvija>0";
    };
    "org/gnome/mutter" = {
      "edge-tiling" = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      "speed" = -0.86;
    };
  };
}
