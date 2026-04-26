{
  pkgs,
  witr,
  ...
}: {
  home.packages = with pkgs; [
    bazelisk
    docker-compose
    evans
    gh
    go
    jdk21
    jetbrains-toolbox
    jujutsu
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    minikube
    mise
    nil
    python3Minimal
    freelens-bin
    witr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
