{
  pkgs,
  witr,
  klados,
  ...
}: {
  home.packages = with pkgs; [
    # bazelisk 1.29.0 ships a stray bin/sha256sum that collides with
    # uutils-coreutils-noprefix; let uutils win.
    (lib.lowPrio bazelisk)
    docker-compose
    evans
    gh
    go
    jdk21
    jetbrains-toolbox
    jujutsu
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    # minikube 1.38.1 bundles its own bin/kubectl; defer to the real one.
    (lib.lowPrio minikube)
    mise
    nil
    python3Minimal
    freelens-bin
    witr.packages.${pkgs.stdenv.hostPlatform.system}.default
    klados.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
