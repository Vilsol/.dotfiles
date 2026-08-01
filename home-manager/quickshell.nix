{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  qs = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Wrapper around upstream quickshell that injects QML_IMPORT_PATH /
  # QT_PLUGIN_PATH / XDG_DATA_DIRS for every Qt and KDE module the
  # dots-hyprland config imports. wrapQtAppsHook crawls buildInputs (and
  # their propagatedBuildInputs) and bakes the right paths into the wrapper
  # script. Without this, kdePackages.kirigami etc. are dev-only wrappers
  # whose `out` is empty, so `home.packages` symlinks nothing usable.
  # Mirrors sdata/dist-nix/home-manager/quickshell.nix upstream.
  quickshell-wrapped = pkgs.stdenv.mkDerivation {
    name = "quickshell-wrapper";

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      qs
      kdePackages.qtwayland
      kdePackages.qtpositioning
      kdePackages.qtlocation
      kdePackages.syntax-highlighting
      gsettings-desktop-schemas
      # https://nixos.wiki/wiki/Qt
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/qt-6/srcs.nix
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qt5compat
      qt6.qtimageformats
      qt6.qtmultimedia
      qt6.qtpositioning
      qt6.qtquicktimeline
      qt6.qtsensors
      qt6.qtsvg
      qt6.qttools
      qt6.qttranslations
      qt6.qtvirtualkeyboard
      qt6.qtwayland
      kdePackages.kirigami
      kdePackages.kdialog
      vulkan-headers
      libdrm
      cpptrace
      jemalloc
      mesa
    ];

    installPhase = ''
      mkdir -p $out/bin
      for bin in qs quickshell; do
        makeWrapper ${qs}/bin/$bin $out/bin/$bin \
          --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      done
    '';
  };
in {
  # dots-hyprland's quickshell collides with DMS's
  # `programs.quickshell.enable = true`, so only one may be installed. Set this
  # true and drop ./dank-material-shell.nix from ./default.nix to swap back.
  options.my.dotsHyprlandShell = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "install the dots-hyprland quickshell wrapper instead of DMS";
  };

  config.fonts.fontconfig.enable = true;

  config.home.packages =
    lib.optional config.my.dotsHyprlandShell quickshell-wrapped
    ++ (with pkgs; [
      ##### Sure #####
      ## Basic cli tool
      ## inetutils: provides hostname, ifconfig, ping, etc.
      ## libnotify: provides notify-send
      inetutils
      libnotify

      ##### Other MISC #####
      dbus
      xlsclients # some basic things
      foot # Used in Quickshell and Hyprland config; its config is also included
      kdePackages.kconfig # provide kwriteconfig6, used in install script

      ##### Not work, to be solved #####
      # hyprlock pamtester

      # NOTE: below are migrated from dist-arch. For each package, must know why it's needed and how it's used specifically, cuz things may be need tweak to properly use the package installed by Nix, for example those have hardcoded path /usr/* . See sdata/deps-info.md
      ### illogical-impulse-audio
      # libcava #cava
      lxqt.pavucontrol-qt #pavucontrol-qt
      wireplumber #wireplumber
      pipewire #pipewire-pulse
      libdbusmenu-gtk3 #libdbusmenu-gtk3
      playerctl #playerctl

      ### illogical-impulse-backlight
      (geoclue2.override {withDemoAgent = true;}) #geoclue
      brightnessctl #brightnessctl
      ddcutil #ddcutil

      ### illogical-impulse-basic
      bc #bc
      uutils-coreutils-noprefix #coreutils
      cliphist #cliphist
      cmake #cmake
      curlFull #curl
      wget #wget
      ripgrep #ripgrep
      jq #jq
      xdg-user-dirs #xdg-user-dirs
      rsync #rsync
      yq-go #go-yq

      ### illogical-impulse-bibata-modern-classic-bin
      bibata-cursors

      ### illogical-impulse-fonts-themes
      adw-gtk3 #adw-gtk-theme-git
      kdePackages.breeze
      kdePackages.breeze-icons #breeze
      #breeze-plus (TODO: Not available as nixpkg)
      darkly
      eza #eza
      #fish (Currently install via system PM; TODO: should install via nix in future when authentication problem fixed)
      fontconfig #fontconfig
      kitty #kitty (Used in fuzzel, Hyprland, kdeglobals and Quickshell config; kitty config is also included as dots)
      matugen #matugen-bin (Used in Quickshell)
      #otf-space-grotesk (TODO: Not available as Nixpkg)
      starship #starship
      nerd-fonts.jetbrains-mono #ttf-jetbrains-mono-nerd
      material-symbols #ttf-material-symbols-variable-git
      #ttf-readex-pro (TODO: seems not available as nixpkg)
      rubik #ttf-rubik-vf
      twemoji-color-font #ttf-twemoji

      ### illogical-impulse-hyprland
      #hyprland
      hyprsunset #hyprsunset
      wl-clipboard #wl-clipboard

      ### illogical-impulse-kde
      kdePackages.bluedevil #bluedevil
      #gnome-keyring #gnome-keyring (TODO: Install via system PM instead; should install via nix in future when authentication problem fixed)
      networkmanager #networkmanager
      kdePackages.plasma-nm #plasma-nm
      #polkit-kde-agent (TODO: Install via system PM instead; should install via nix in future when authentication problem fixed)
      kdePackages.dolphin #dolphin
      kdePackages.systemsettings #systemsettings

      ### illogical-impulse-microtex-git
      # TODO: Not available as nixpkg

      ### illogical-impulse-portal
      #xdg-desktop-portal (Included elsewhere)
      #xdg-desktop-portal-kde (Included elsewhere)
      #xdg-desktop-portal-gtk (Included elsewhere)
      #xdg-desktop-portal-hyprland (Included elsewhere)

      ### illogical-impulse-python
      #clang (Not needed for Nix. However, when cmake is installed by Nix, then pkg-config, cairo etc will be used but they can only be accessible in Nix development environment for example nix-shell, nix develop, etc. See `sdata/uv/shell.nix`. )
      uv #uv
      gtk4 #gtk4
      libadwaita #libadwaita
      libsoup_3 #libsoup3
      libportal-gtk4 #libportal-gtk4
      gobject-introspection #gobject-introspection

      ### illogical-impulse-screencapture
      hyprshot #hyprshot
      slurp #slurp
      swappy #swappy
      tesseract #tesseract
      #tesseract-data-eng (TODO: Seems not available as nixpkg)
      wf-recorder #wf-recorder

      ### illogical-impulse-toolkit
      upower #upower
      wtype #wtype
      ydotool #ydotool

      ### illogical-impulse-widgets
      fuzzel #fuzzel
      glib #glib2
      imagemagick #imagemagick
      hypridle #hypridle
      #hyprlock (Should not be installed via Nix; TODO: should install via nix in future when authentication problem fixed)
      hyprpicker #hyprpicker
      songrec #songrec
      translate-shell #translate-shell
      wlogout #wlogout
      libqalculate #libqalculate
    ]);
}
