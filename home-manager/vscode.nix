{pkgs, ...}: let
  extensionsList = with pkgs.vscode-marketplace; [
    antyos.vscode-mlog
    arrterian.nix-env-selector
    # asciidoctor.asciidoctor-vscode
    b4dm4n.nixpkgs-fmt
    bbenoist.nix
    brettm12345.nixfmt-vscode
    # coolbear.systemd-unit-file
    eamodio.gitlens
    fabiospampinato.vscode-diff
    golang.go
    iliazeus.vscode-ansi
    jnoortheen.nix-ide
    mechatroner.rainbow-csv
    (mhutchie.git-graph.override {meta.license = [];})
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    (ms-vscode-remote.remote-containers.override {meta.license = [];})
    (ms-vscode-remote.remote-ssh.override {meta.license = [];})
    (ms-vscode-remote.remote-ssh-edit.override {meta.license = [];})
    ms-vscode.hexeditor
    (ms-vscode.remote-explorer.override {meta.license = [];})
    ms-vscode.vscode-typescript-next
    ms-vsliveshare.vsliveshare
    oderwat.indent-rainbow
    platformio.platformio-ide
    rafaelmaiolla.diff
    redhat.vscode-yaml
    rokoroku.vscode-theme-darcula
    rreverser.llvm
    sumneko.lua
    svelte.svelte-vscode
    tamasfe.even-better-toml
    tangzx.emmylua
    tilt-dev.tiltfile
    # pkgs.vscode-extensions.visualjj.visualjj
    vrtlabs.vscode-lsl
    weaveworks.vscode-gitops-tools
    zxh404.vscode-proto3
    ms-python.python
    ms-python.debugpy
    bbenoist.qml
  ];
in {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    package = pkgs.vscode;
    profiles.default = {
      extensions = extensionsList;
    };
  };
}
