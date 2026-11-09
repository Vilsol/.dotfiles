# eMudhra G3B/G3C ECC intermediates have trivially small private keys (0x4, 0x42, ...).
# NSS dropped the emSign ECC G3 root as of 3.131; Chromium uses its own root store, so distrust there.
{lib, ...}: let
  pemToBase64 = f: lib.concatStrings (lib.filter (l: !lib.hasPrefix "-----" l) (lib.splitString "\n" (builtins.readFile f)));
  certs = lib.mapAttrsToList (name: _: ./distrusted-certs + "/${name}") (builtins.readDir ./distrusted-certs);
in {
  programs.chromium = {
    enable = true;
    extraOpts.CADistrustedCertificates = map pemToBase64 certs;
  };
}
