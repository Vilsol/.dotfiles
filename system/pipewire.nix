{unstable, ...}: {
  services.pipewire.jack.enable = true;

  systemd.user.services.easyeffects = {
    enable = true;
    description = "Start EasyEffects service";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''${unstable.easyeffects}/bin/easyeffects --gapplication-service'';
    wantedBy = ["multi-user.target"];
  };
}
