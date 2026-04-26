{pkgs, ...}: {
  services.pipewire.jack.enable = true;

  # systemd.user.services.easyeffects = {
  #   enable = true;
  #   description = "Start EasyEffects service";
  #   serviceConfig = {
  #     PassEnvironment = "DISPLAY";
  #     ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
  #     Restart = "on-failure";
  #   };
  #   environment = {
  #     QT_STYLE_OVERRIDE = "Breeze";
  #   };
  #   wantedBy = ["graphical-session.target"];
  #   after = ["graphical-session.target" "pipewire.socket" "pipewire-pulse.socket"];
  # };

  environment.systemPackages = with pkgs; [
    adwaita-qt
  ];
}
