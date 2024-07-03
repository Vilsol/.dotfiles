{
  unstable,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (prismlauncher.override {jdks = [jdk8 jdk17];})
    dxvk
    heroic
    mangohud
    protonup-qt
    unstable.bottles
    unstable.path-of-building
    vkd3d-proton
  ];
}
