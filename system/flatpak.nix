{
  config,
  lib,
  ...
}: {
  services.flatpak = {
    enable = true;

    update.onActivation = true;

    packages =
      [
        {
          appId = "com.valvesoftware.Steam";
          origin = "flathub";
        }
        {
          appId = "com.github.iwalton3.jellyfin-media-player";
          origin = "flathub";
        }
        {
          appId = "com.github.tchx84.Flatseal";
          origin = "flathub";
        }
        {
          appId = "tv.plex.PlexDesktop";
          origin = "flathub";
        }
        {
          appId = "org.signal.Signal";
          origin = "flathub";
        }
      ]
      ++ lib.optionals config.full-desktop [
        {
          appId = "org.darktable.Darktable";
          origin = "flathub";
        }
        # {
        #   appId = "com.leinardi.gwe";
        #   origin = "flathub";
        # }
      ];
  };
}
