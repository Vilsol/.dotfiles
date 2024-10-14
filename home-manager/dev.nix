{pkgs, ...}: {
  home.packages = with pkgs; [
    docker-compose
    evans
    helmfile
    jdk21
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    minikube
    python3Full
    devbox
    gh
    jetbrains-toolbox
    lens
    nil
    crane
  ];
}
