{
  description = "NixOS configuration";

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "flake:nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable-small.url = "flake:nixpkgs/nixos-unstable-small";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.3.0";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
      };
    };

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        agenix.follows = "agenix";
        flake-utils.follows = "flake-utils";
      };
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    nix-flatpak,
    nix-vscode-extensions,
    pre-commit-hooks,
    flake-utils,
    ragenix,
    nixos-hardware,
    nixpkgs-unstable-small,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs-unstable {
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
          unstable = import nixpkgs-unstable {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };
          small = import nixpkgs-unstable-small {
            inherit system;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };
          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true;
          config.full-desktop = is-full-desktop;
          config.android_sdk.accept_license = true;

          extensions = inputs.nix-vscode-extensions.extensions.${system};

          buildToolsVersion = "34.0.0";
          androidComposition = unstable.androidenv.composeAndroidPackages {
            buildToolsVersions = [buildToolsVersion "28.0.3"];
            platformVersions = ["34" "28"];
            abiVersions = ["armeabi-v7a" "arm64-v8a"];
            includeEmulator = true;
            extraLicenses = [
              "android-sdk-license"
            ];
          };

          specialArgs = {
            inherit system unstable nixpkgs extensions androidComposition nixos-hardware small;
          };

          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            ragenix.nixosModules.default
            {
              config.environment.systemPackages = [ragenix.packages.${system}.default];
              config.full-desktop = is-full-desktop;
            }

            (./. + "/system/machines/${name}/configuration.nix")
            (./. + "/system/machines/${name}.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.vilsol = {
                  config,
                  lib,
                  ...
                }: {
                  imports = [
                    ragenix.homeManagerModules.default
                    ./system/home-manager/default.nix
                  ];

                  config = {
                    age = {
                      secretsDir = "${config.home.homeDirectory}/.agenix/agenix";
                      secretsMountPoint = "${config.home.homeDirectory}/.agenix/agenix.d";
                    };
                  };

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
