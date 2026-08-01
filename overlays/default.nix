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
