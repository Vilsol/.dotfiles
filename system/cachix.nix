{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cachix
  ];

  # attic.xuyh0120.win/lantian (nix-cachyos-kernel) removed 2026-10-17: the
  # maintainer's servers were compromised (xddxdd/nix-cachyos-kernel#110).
  # Re-add only once they announce a rebuild and confirm or rotate the key.
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
      # Serves the CUDA toolchain (cuda-maintainers.cachix.org is gone, 401). Latent:
      # ./ai.nix pins pkgs.ollama-cuda, so this matters the moment services.ollama is
      # enabled -- without it that pulls the CUDA stack from source.
      "https://nix-community.cachix.org"
    ];
    # Mirrors `substituters` above: both lists name the same caches, so an
    # untrusted user can select any cache the system already trusts.
    trusted-substituters = [
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
