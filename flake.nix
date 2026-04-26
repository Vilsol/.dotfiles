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

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    witr = {
      url = "github:pranshuparmar/witr";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.54.3";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces?ref=v0.54.2";
      inputs.hyprland.follows = "hyprland";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae";
    };

    hyprshell = {
      url = "github:H3rmt/hyprshell?ref=hyprshell-release";
      inputs.hyprland.follows = "hyprland";
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
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-vscode-extensions,
    pre-commit-hooks,
    flake-utils,
    nixos-hardware,
    nur,
    nix-cachyos-kernel,
    witr,
    vicinae,
    solaar,
    quickshell,
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
            inherit inputs system nixpkgs extensions androidComposition nixos-hardware witr quickshell;
          };

          modules = [
            {
              config.full-desktop = is-full-desktop;
            }

            {
              nixpkgs.overlays = [nix-cachyos-kernel.overlays.pinned];
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

            nur.modules.nixos.default
            ({pkgs, ...}: {
              environment.systemPackages = [pkgs.nur.repos.xddxdd.flaresolverr-21hsmw];
            })
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
