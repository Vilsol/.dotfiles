{
  description = "NixOS configuration";

  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "flake:nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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

    hyprshell = {
      url = "github:H3rmt/hyprshell?ref=hyprshell-release";
    };

    lan-mouse = {
      url = "github:feschber/lan-mouse";
    };

    solaar = {
      # Not the flakehub tarball: Lix locks that URL with ?rev=&revCount=
      # query params, upstream Nix re-fetches it without them, and
      # fetchTreeFinal then rejects the mismatch -- so a Lix-written lock could
      # not be evaluated in CI. A github: input round-trips under both.
      # Tracks the default branch rather than the newest release.
      url = "github:Svenum/Solaar-Flake";
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
      url = "github:Vilsol/klados";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    pre-commit-hooks,
    flake-utils,
    solaar,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        # Plain nixpkgs: this shell only runs the pre-commit hooks, so it needs
        # neither the overlays nor the config the machines use.
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        formatter = pkgs.alejandra;

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
          # Every module reaches flake inputs as `inputs.<name>`, so adding an
          # input needs no change here.
          specialArgs = {inherit inputs;};

          modules = [
            {
              nixpkgs.overlays = import ./overlays inputs;
            }

            solaar.nixosModules.default

            (./. + "/system/machines/${name}/configuration.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.vilsol = {
                  imports = [./home-manager/default.nix];
                  my.fullDesktop = is-full-desktop;
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
