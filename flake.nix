{
  description = "NixOS configuration";

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "flake:nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.3.0";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    witr = {
      url = "github:pranshuparmar/witr";
    };

    hyprland = {
      # Pinned to the 0.56.0 release: master has removed Config::CONFIG_LEGACY
      # and made CKeybindManager::m_dispatchers private, which breaks
      # split-monitor-workspaces (it follows this input). Unpin once the plugin
      # builds against a newer Hyprland.
      url = "github:hyprwm/Hyprland/v0.56.0";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
    };

    hyprshell = {
      url = "github:H3rmt/hyprshell?ref=hyprshell-release";
    };

    lan-mouse = {
      url = "github:feschber/lan-mouse";
    };

    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      # Pinned to 1.9255.2 (last release before the 1.9659.2 bump, whose
      # patcher fails with "addTrustedFolder anchor not found"; see upstream
      # issue #677). Revert to unpinned HEAD once the fix PR #674 merges.
      url = "github:aaddrick/claude-desktop-debian/5dd948e96d853ed37636bc0e2368fc2665cd1104";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    klados = {
      url = "git+file:///home/vilsol/Projects/Vilsol/klados";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
    pre-commit-hooks,
    flake-utils,
    nixos-hardware,
    nix-cachyos-kernel,
    witr,
    vicinae,
    solaar,
    quickshell,
    dank-material-shell,
    klados,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      in {
        checks = {
          pre-commit-hooks = pre-commit-hooks.lib.${system}.run {
            hooks = {
              alejandra.enable = true;
              statix.enable = true;
              deadnix.enable = true;
            };

            src = ./.;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-hooks) shellHook;
        };
      }
    )
    // (
      let
        mkSystem = system: name: is-full-desktop: let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
            overlays = [
              nix-cachyos-kernel.overlays.pinned
              nix-vscode-extensions.overlays.default
              inputs.claude-desktop.overlays.default
            ];
          };

          extensions = pkgs;

          buildToolsVersion = "34.0.0";
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = [buildToolsVersion "28.0.3"];
            platformVersions = ["34" "28"];
            abiVersions = ["armeabi-v7a" "arm64-v8a"];
            includeEmulator = true;
            extraLicenses = [
              "android-sdk-license"
            ];
          };

          specialArgs = {
            inherit inputs system nixpkgs extensions androidComposition nixos-hardware witr quickshell dank-material-shell klados;
          };

          modules = [
            {
              config.full-desktop = is-full-desktop;
            }

            {
              nixpkgs.overlays = [
                nix-cachyos-kernel.overlays.pinned
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
              ];
            }

            solaar.nixosModules.default

            (./. + "/system/machines/${name}/configuration.nix")
            (./. + "/system/machines/${name}.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.vilsol = {lib, ...}: {
                  imports = [
                    vicinae.homeManagerModules.default
                    ./system/home-manager/default.nix
                  ];

                  options = {
                    full-desktop = lib.mkOption {
                      type = lib.types.bool;
                      default = is-full-desktop;
                      description = "include all desktop software and settings";
                    };
                  };
                };
                extraSpecialArgs = specialArgs;
              };
            }
          ];
        in
          nixpkgs.lib.nixosSystem {
            inherit system modules specialArgs;
          };
      in {
        nixosConfigurations = {
          cortex = mkSystem "x86_64-linux" "cortex" true;
          framework = mkSystem "x86_64-linux" "framework" false;
        };
      }
    );
}
