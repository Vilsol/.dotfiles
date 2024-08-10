{pkgs, ...}: {
  services.pipewire.jack.enable = true;

  systemd.user.services.easyeffects = {
    enable = true;
    description = "Start EasyEffects service";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''${pkgs.easyeffects}/bin/easyeffects --gapplication-service'';
    wantedBy = ["sockets.target"];
    after = ["pipewire.socket" "pipewire-pulse.socket"];
  };
}
