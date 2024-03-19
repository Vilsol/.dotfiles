{
  unstable,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mangohud
    unstable.bottles
    dxvk
    vkd3d-proton
    protonup-qt
    lutris
    heroic
    (prismlauncher.override {jdks = [jdk8 jdk17 jdk19];})
    unstable.path-of-building
  ];
}
