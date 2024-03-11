{
  unstable,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mangohud
    bottles
    dxvk
    vkd3d-proton
    protonup-qt
    lutris
    heroic
    prismlauncher
    unstable.path-of-building
  ];
}
