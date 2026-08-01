{pkgs, ...}: {
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = "Noto Sans Nerd Font";
      size = 11;
    };

    gtk3.extraCss = ''
      /* Customize dropdown/context menus */
      menu,
      .menu,
      .context-menu {
        background-color: rgba(30, 30, 46, 0.95);
        color: #cdd6f4;
        border: 1px solid rgba(137, 180, 250, 0.3);
        border-radius: 8px;
        padding: 4px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
      }

      /* Menu items */
      menuitem,
      .menuitem {
        padding: 8px 12px;
        border-radius: 4px;
        transition: all 200ms ease;
      }

      /* Menu item hover */
      menuitem:hover,
      .menuitem:hover {
        background-color: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      /* Menu item selected/active */
      menuitem:active,
      .menuitem:active,
      menuitem:selected,
      .menuitem:selected {
        background-color: rgba(137, 180, 250, 0.3);
      }

      /* Menu separators */
      separator,
      .separator {
        background-color: rgba(137, 180, 250, 0.2);
        min-height: 1px;
        margin: 4px 8px;
      }

      /* Disabled menu items */
      menuitem:disabled,
      .menuitem:disabled {
        color: #6c7086;
      }

      /* Menu arrows/indicators */
      menuitem arrow,
      .menuitem arrow {
        min-height: 16px;
        min-width: 16px;
      }

      /* Checkboxes and radio buttons in menus */
      menuitem check,
      menuitem radio {
        min-height: 16px;
        min-width: 16px;
        margin-right: 8px;
      }
    '';

    gtk4.theme = null;
    gtk4.extraCss = ''
      /* GTK4 menu styling */
      popover.menu,
      popover.background.menu {
        background-color: rgba(30, 30, 46, 0.95);
        color: #cdd6f4;
        border: 1px solid rgba(137, 180, 250, 0.3);
        border-radius: 8px;
        padding: 4px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
      }

      /* GTK4 menu items */
      popover.menu box.vertical > modelbutton,
      popover.menu modelbutton {
        padding: 8px 12px;
        border-radius: 4px;
      }

      popover.menu box.vertical > modelbutton:hover,
      popover.menu modelbutton:hover {
        background-color: rgba(137, 180, 250, 0.2);
        color: #89b4fa;
      }

      /* GTK4 menu separators */
      popover.menu separator {
        background-color: rgba(137, 180, 250, 0.2);
        min-height: 1px;
        margin: 4px 8px;
      }
    '';
  };

  # Ensure GTK settings are applied for Hyprland
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };

  # Interface scaling for GTK/WebKitGTK/Electron apps (read via the GNOME
  # settings portal). Moved here from the disabled gnome.nix so it survives
  # without pulling in gnome-shell config.
  dconf.settings."org/gnome/desktop/interface" = {
    "text-scaling-factor" = 1.5;
    "cursor-size" = 32;
  };

  # Qt theming to match GTK (for Qt-based tray icons)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
