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
    unstable.devbox
    gh
    jetbrains-toolbox
    lens
    nil
    crane
  ];
}
