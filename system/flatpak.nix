{
  config,
  lib,
  ...
}: {
  services.flatpak = {
    enable = true;

    # update.onActivation = true;

    # packages =
    #   [
    #     {
    #       appId = "com.github.tchx84.Flatseal";
    #       origin = "flathub";
    #     }
    #     {
    #       appId = "org.signal.Signal";
    #       origin = "flathub";
    #     }
    #   ]
    #   ++ lib.optionals config.full-desktop [
    #     {
    #       appId = "org.darktable.Darktable";
    #       origin = "flathub";
    #     }
    #   ];
  };
}
