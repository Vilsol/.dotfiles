{pkgs, witr, ...}: {
  home.packages = with pkgs; [
    bazelisk
    code-cursor
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
    glow
    delta
    witr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
