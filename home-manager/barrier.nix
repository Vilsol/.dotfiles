{
  pkgs,
  unstable,
  config,
  ...
}: {
  age.secrets.barrier-pem.file = ../secrets/barrier-pem.age;
  age.secrets.barrier-fingerprints.file = ../secrets/barrier-fingerprints.age;

  # services.barrier.client = {
  #   enable = true;
  #   server = "192.168.1.111";
  # };

  home = {
    file.".local/share/barrier/SSL/Barrier.pem".source = config.lib.file.mkOutOfStoreSymlink config.age.secrets.barrier-pem.path;
    file.".local/share/barrier/SSL/Fingerprints/Local.txt".source = config.lib.file.mkOutOfStoreSymlink config.age.secrets.barrier-fingerprints.path;

    packages = with pkgs; [
      unstable.barrier
      openssl
    ];
  };
}
