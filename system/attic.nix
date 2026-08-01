{pkgs, ...}: let
  # Attic server (Tailscale-only) and the public-readable cache on it.
  endpoint = "https://attic.tailde002.ts.net";
  cache = "venus";
  # Local server alias used by `attic login <alias> ${endpoint} <token>`.
  # The push service references the cache as "<alias>:${cache}".
  serverAlias = "home";

  # Public signing key for the cache. Fill in after making the cache public:
  #   attic login ${serverAlias} ${endpoint} <token>
  #   attic cache configure ${cache} --public
  #   attic cache info ${cache}      # copy the "Public Key" line here
  publicKey = "venus:5P4LW13LSns8vFqXJDmBvF8fq8IPZ/N4uCIGP8p+i1Q=";

  cacheUrl = "${endpoint}/${cache}";
in {
  environment.systemPackages = [pkgs.attic-client];

  # Pull side (public cache: only the public key is needed, no token).
  # Merges/concatenates with the lists in ./cachix.nix.
  nix.settings = {
    substituters = [cacheUrl];
    trusted-substituters = [cacheUrl];
    trusted-public-keys = [publicKey];
  };

  # Push side: watch the store and upload every new path. Reads the auth token
  # from ~/.config/attic/config.toml, populated once by `attic login` above.
  systemd.user.services.attic-watch-store = {
    description = "Push new store paths to Attic (${cache})";
    wantedBy = ["default.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      ExecStart = "${pkgs.attic-client}/bin/attic watch-store ${serverAlias}:${cache}";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
