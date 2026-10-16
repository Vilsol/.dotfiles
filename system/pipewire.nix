{pkgs, ...}: {
  services.pipewire.jack.enable = true;

  # The default pick is IEC958, which has no mixer path, so the volume slider is
  # software-only and the Yeti's hardware Mic gain sits wherever it was left.
  # A profile stored in ~/.local/state/wireplumber/default-profile still wins.
  services.pipewire.wireplumber.extraConfig."51-yeti-profile" = {
    "device.profile.priority.rules" = [
      {
        matches = [{"device.name" = "~alsa_card.usb-Blue_Microphones_Yeti_*";}];
        actions.update-props.priorities = ["input:analog-stereo"];
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    adwaita-qt
  ];
}
