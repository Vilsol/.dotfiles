{
  unstable,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (prismlauncher.override {jdks = [jdk8 jdk17 jdk19];})
    dxvk
    heroic
    lutris
    mangohud
    protonup-qt
    unstable.bottles
    unstable.path-of-building
    vkd3d-proton
  ];
}
