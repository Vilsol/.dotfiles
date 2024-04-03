{
  pkgs,
  unstable,
  config,
  ...
}: {
  age.secrets.barrier-pem.file = ../secrets/barrier-pem.age;
  age.secrets.barrier-fingerprints.file = ../secrets/barrier-fingerprints.age;

  services.barrier.client =
    if ! config.full-desktop
    then {
      enable = true;
      server = "192.168.1.100";
    }
    else {};

  home = {
    file.".local/share/barrier/SSL/Barrier.pem".source = config.lib.file.mkOutOfStoreSymlink config.age.secrets.barrier-pem.path;
    file.".local/share/barrier/SSL/Fingerprints/Local.txt".source = config.lib.file.mkOutOfStoreSymlink config.age.secrets.barrier-fingerprints.path;

    packages = with pkgs; [
      unstable.barrier
      openssl
    ];
  };
}
