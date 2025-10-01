{pkgs, ...}: {
  home.packages = with pkgs; [
    bazelisk
    crane
    devbox
    docker-compose
    evans
    gh
    go
    helmfile
    jdk21
    jetbrains-toolbox
    jujutsu
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    lens
    minikube
    mise
    nil
    python3Minimal
    libtas
  ];
}
