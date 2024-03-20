{
  description = "NixOS configuration";

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "flake:nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
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
      inputs.flake-utils.follows = "flake-utils";
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
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
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
        mkSystem = system: name: let
          unstable = import nixpkgs-unstable {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = ["electron-25.9.0"];
              android_sdk.accept_license = true;
            };
          };

          config.allowUnfree = true;
          config.segger-jlink.acceptLicense = true;

          extensions = inputs.nix-vscode-extensions.extensions.${system};

          buildToolsVersion = "34.0.0";
          androidComposition = unstable.androidenv.composeAndroidPackages {
            buildToolsVersions = [buildToolsVersion "28.0.3"];
            platformVersions = ["34" "28"];
            abiVersions = ["armeabi-v7a" "arm64-v8a"];
          };
          androidSdk = androidComposition.androidsdk;

          specialArgs = {
            inherit system unstable nixpkgs extensions androidSdk;
          };

          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            ragenix.nixosModules.default
            {
              environment.systemPackages = [ragenix.packages.${system}.default];
            }

            (./. + "/system/machines/${name}/configuration.nix")
            (./. + "/system/machines/${name}.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.vilsol = import ./system/home-manager/default.nix;
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
          cortex = mkSystem "x86_64-linux" "cortex";
          framework = mkSystem "x86_64-linux" "framework";
        };
      }
    );
}
