{
  pkgs,
  small,
  ...
}: {
  home.packages = with pkgs; [
    (prismlauncher.override {jdks = [jdk8 jdk17];})
    dxvk
    heroic
    mangohud
    protonup-qt
    bottles
    small.path-of-building
    vkd3d-proton
  ];
}
