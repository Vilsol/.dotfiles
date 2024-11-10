{
  pkgs,
  extensions,
  ...
}: let
  extensionsList = with extensions.vscode-marketplace; [
    antyos.vscode-mlog
    arrterian.nix-env-selector
    asciidoctor.asciidoctor-vscode
    b4dm4n.nixpkgs-fmt
    bbenoist.nix
    brettm12345.nixfmt-vscode
    continue.continue
    coolbear.systemd-unit-file
    eamodio.gitlens
    fabiospampinato.vscode-diff
    github.copilot
    golang.go
    huber-baste.msgpack
    iliazeus.vscode-ansi
    jetpack-io.devbox
    jnoortheen.nix-ide
    kraftwer1.darcula-extra
    mechatroner.rainbow-csv
    mhutchie.git-graph
    mkhl.direnv
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
    ms-vscode.hexeditor
    ms-vscode.remote-explorer
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
    vrtlabs.vscode-lsl
    weaveworks.vscode-gitops-tools
    zxh404.vscode-proto3
  ];
in {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions = extensionsList;
    package = pkgs.vscode;
    userSettings = {
      "editor.largeFileOptimizations" = false;
      "go.lintTool" = "golint";
      "workbench.colorTheme" = "Darcula";
      "editor.unicodeHighlight.nonBasicASCII" = false;
      "git.confirmSync" = false;
      "git.autofetch" = true;
      "svelte.enable-ts-plugin" = true;
      "Lua.telemetry.enable" = true;
      "Lua.workspace.preloadFileSize" = 5000;
      "hexeditor.columnWidth" = 32;
      "hexeditor.showDecodedText" = true;
      "hexeditor.defaultEndianness" = "little";
      "hexeditor.inspectorType" = "aside";
      "editor.selectionClipboard" = false;
      "vs-kubernetes" = {
        "vs-kubernetes.crd-code-completion" = "enabled";
      };
      "json.maxItemsComputed" = 50000;
      "[python]" = {
        "editor.formatOnType" = true;
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "nix.enableLanguageServer" = true;
    };
  };
}
