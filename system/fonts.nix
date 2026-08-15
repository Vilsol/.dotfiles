{pkgs, ...}: {
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };

  fonts.packages = with pkgs; [
    carlito
    dejavu_fonts
    ipaexfont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    powerline-fonts
  ];

  # services.desktopManager.gnome mkDefaults this to true+ibus, which autostarts
  # ibus-daemon --xim under Hyprland and pops a "IBus should be called from the
  # desktop session" notification on every login.
  i18n.inputMethod.enable = false;
}
