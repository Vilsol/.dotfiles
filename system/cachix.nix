{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cachix
  ];

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://cuda-maintainers.cachix.org"
      "https://ezkea.cachix.org"
      "https://attic.corp.cofractal.com/ci-cache"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      "ci-cache:9Znhwbc4NUxZaklRJw/TA88RIOTJrcEpaDiQXZbXwPk="
    ];
  };
}
