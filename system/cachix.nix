{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cachix
  ];

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      # Latent: nothing in the closure needs it today, but cudaSupport is on,
      # so it matters the moment services.ollama is enabled.
      "https://cuda-maintainers.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://hyprland.cachix.org"
    ];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };
}
