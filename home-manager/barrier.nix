{
  pkgs,
  unstable,
  ...
}: {
  # services.barrier.client = {
  #   enable = true;
  #   server = "192.168.1.111";
  # };
  home.packages = with pkgs; [
    unstable.barrier
    openssl
  ];
}
