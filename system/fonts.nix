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
  ];

  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [mozc];
  # i18n.inputMethod.enabled = "fcitx";
  # i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
}
