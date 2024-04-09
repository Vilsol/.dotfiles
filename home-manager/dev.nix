{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    docker-compose
    evans
    helmfile
    jdk21
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    minikube
    python3Full
    rustup
    unstable.devbox
    unstable.gh
    unstable.jetbrains-toolbox
    unstable.lens
  ];
}
