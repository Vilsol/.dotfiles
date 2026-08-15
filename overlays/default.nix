# Single source of overlays. Imported by the NixOS module system so that every
# `pkgs` in this flake -- system modules and home-manager alike (useGlobalPkgs
# is on) -- resolves against the same package set.
inputs: [
  inputs.nix-cachyos-kernel.overlays.pinned
  inputs.nix-vscode-extensions.overlays.default
  inputs.claude-desktop.overlays.default

  (_final: prev:
    if prev.stdenv.hostPlatform.system == "i686-linux"
    then {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    }
    else {})

  # wf-recorder's audio path still reads AVCodec.sample_fmts, which ffmpeg 8
  # removed -- upstream master has not fixed it either, so it cannot build
  # against the ffmpeg 9 nixpkgs now defaults to. Drop once upstream ports the
  # audio code to avcodec_get_supported_config.
  (_final: prev: {
    wf-recorder = prev.wf-recorder.override {ffmpeg = prev.ffmpeg_7;};
  })

  # patool's tests fail under python 3.14 (nixpkgs#540025); it is
  # only pulled in as a bottles library dep. pytestCheckHook runs
  # in installCheckPhase, so doCheck is not the flag to unset.
  # Drop once that issue closes.
  (_final: prev: {
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (_pyFinal: pyPrev: {
          patool = pyPrev.patool.overrideAttrs (_: {
            doInstallCheck = false;
          });
        })
      ];
  })
]
