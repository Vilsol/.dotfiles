let
  key1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbO0LNSfMZg9L7uZ8+5dH2COk5eqnELsxqiOWUH4zPq";
  keys = [key1];
in {
  "barrier-pem.age".publicKeys = keys;
  "barrier-fingerprints.age".publicKeys = keys;
}
