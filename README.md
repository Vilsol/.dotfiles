# .dotfiles

NixOS + home-manager configuration for two machines.

| Machine | Attribute | Notes |
| --- | --- | --- |
| `cortex` | `nixosConfigurations.cortex` | Desktop. NVIDIA, `performance` governor, full desktop. |
| `framework` | `nixosConfigurations.framework` | Laptop. `nixos-hardware` framework-12th-gen-intel. |

## Rebuilding

Aliases from `home-manager/zsh.nix`:

| Alias | Runs |
| --- | --- |
| `up` | `nh os switch ~/.dotfiles -v --ask` |
| `upb` | `nh os boot ~/.dotfiles -v --ask` |
| `upgrade` | `up` plus `-u`, which updates flake inputs first |
| `upgradeb` | `upb` plus `-u` |

Without `nh`:

```sh
sudo nixos-rebuild switch --flake ~/.dotfiles#cortex
```

To build without activating, which is the safe way to check a change:

```sh
nix build .#nixosConfigurations.cortex.config.system.build.toplevel --no-link --print-out-paths
nix store diff-closures /run/current-system <the-path-just-printed>
```

Empty `diff-closures` output means the change altered no packages.

New files must be `git add`ed before nix can see them -- the flake is read from
the git tree, not the working directory.

## Layout

```
flake.nix              inputs, mkSystem, nixosConfigurations
overlays/              every overlay, applied via nixpkgs.overlays
system/                NixOS modules, imported by system/default.nix
system/nixpkgs.nix     repo-wide nixpkgs.config
system/machines/       per-machine config and hardware-configuration
home-manager/          home-manager modules, imported by home-manager/default.nix
home-manager/files/    dotfile payloads, symlinked out of store (see below)
```

`home-manager/files/` is mapped into `$HOME` by `home-manager/files.nix`, which
walks the directory and creates `mkOutOfStoreSymlink` entries. Those point at
the working copy rather than the Nix store, so edits take effect without a
rebuild -- and so **the repo's path on disk is load-bearing**. It is hardcoded
as `localFlakeRoot` in `home-manager/files.nix`; moving the repo means updating
it.

## Checks

`nix flake check` runs alejandra, statix and deadnix via `pre-commit-hooks`.
Entering the dev shell (`direnv allow`, or `nix develop`) installs the git
pre-commit hook. `nix fmt` formats with alejandra.

`system/machines/<name>.nix` is imported by string interpolation in `flake.nix`,
so deadnix cannot see those files as referenced.

## Binary caches

Configured in `system/cachix.nix`, plus a personal attic cache in
`system/attic.nix` that also pushes every locally built path. A substituter that
goes offline does not degrade gracefully -- nix retries, then fails the build --
so caches serving nothing are not kept.
