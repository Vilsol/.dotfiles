{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  yetiInput = "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8_2017_9_29_80297-00.analog-stereo";

  # Ordering after wireplumber only guarantees the session manager started, not
  # that USB enumeration finished, so block on the node actually existing.
  # Always exits 0: a missing mic must not wedge the boot.
  waitForNode = pkgs.writeShellScript "wait-for-pw-node" ''
    for _ in $(seq 100); do
      if ${pkgs.pipewire}/bin/pw-cli ls Node 2>/dev/null | grep -qF "$1"; then exit 0; fi
      sleep 0.2
    done
    echo "wait-for-pw-node: '$1' never appeared after 20s, starting anyway" >&2
  '';

  speakersOutput = "alsa_output.usb-Speed_Dragon_Fosi_Audio_DS2_5000000001-01.analog-stereo";

  # Linux Broadcast RTX 20 portable bundle (github.com/arzvaak/linux-broadcast):
  # NVIDIA AFX + CUDA + TensorRT, 2.6 GB of proprietary libraries, so it lives
  # outside the store. Download linux-broadcast-<ver>-rtx20-x86_64.tar and extract
  # its directory here.
  afxBundle = "${config.home.homeDirectory}/.local/share/linux-broadcast/bundle";

  # Standalone PipeWire clients, so each graph runs in its own process with its
  # own RT data thread instead of inside the daemon.
  pipewireClient = name: modules:
    pkgs.writeText "${name}.conf" ''
      context.properties = { log.level = 2 }
      context.spa-libs = {
        audio.convert.* = audioconvert/libspa-audioconvert
        support.*       = support/libspa-support
      }
      context.modules = [
        { name = libpipewire-module-rt args = { } flags = [ ifexists nofail ] }
        { name = libpipewire-module-protocol-native }
        { name = libpipewire-module-client-node }
        { name = libpipewire-module-adapter }
        ${modules}
      ]
    '';

  # DeepFilterNet/AFX keep YouTube from the speakers because it is speech, so
  # subtract playback first. Everything must play into ec_sink (set it as the
  # default output) or it is missing from the reference.
  echoCancelConf = pipewireClient "echo-cancel" ''
    { name = libpipewire-module-echo-cancel
      args = {
        library.name = aec/libspa-aec-webrtc
        node.latency = 960/48000
        aec.args = {
          webrtc.extended_filter   = true
          webrtc.high_pass_filter  = true
          webrtc.noise_suppression = false
          webrtc.gain_control      = false
        }
        capture.props = {
          node.name      = "ec_capture"
          node.passive   = true
          target.object  = "${yetiInput}"
          # Stay on the Yeti; never follow default-source changes.
          node.dont-move = true
          audio.position = [ MONO ]
        }
        source.props = {
          node.name        = "ec_source"
          node.description = "Echo Cancel Source"
          audio.position   = [ MONO ]
          priority.session = 0
        }
        sink.props = {
          node.name        = "ec_sink"
          node.description = "Echo Cancel Sink"
          audio.position   = [ FL FR ]
        }
        playback.props = {
          node.name      = "ec_playback"
          target.object  = "${speakersOutput}"
          node.dont-move = true
          audio.position = [ FL FR ]
        }
      }
    }
  '';

  # BNR 2.0 runs synchronously in the RT data thread on the GPU, unlike
  # DeepFilterNet's LADSPA plugin, whose SCHED_OTHER worker starves under load.
  afxMicConf = pipewireClient "afx-mic" ''
    { name = libpipewire-module-filter-chain
      args = {
        node.description = "AFX Microphone"
        media.name       = "AFX Microphone"
        filter.graph = {
          nodes = [
            { type = ladspa name = afx
              plugin = "${afxBundle}/liblinux_broadcast_afx_ladspa.so"
              label = linux_broadcast_bnr2
              control = { "Intensity" = 1.0 } }
          ]
        }
        audio.rate     = 48000
        audio.position = [ MONO ]
        capture.props = {
          node.name          = "afx_mic.capture"
          node.passive       = true
          target.object      = "ec_source"
          node.dont-fallback = true
          node.dont-move     = true
        }
        playback.props = {
          node.name        = "afx_mic"
          node.description = "AFX Microphone"
          media.class      = Audio/Source
          node.virtual     = true
          priority.session = 0
        }
      }
    }
  '';

  afxSdk = "${afxBundle}/nvidia";
  afxLibraryPath = lib.concatStringsSep ":" [
    "${afxSdk}/nvafx/lib"
    "${afxSdk}/features/denoiser/lib"
    "${afxSdk}/features/dereverb/lib"
    "${afxSdk}/features/dereverb_denoiser/lib"
    "${afxSdk}/features/studio_voice/lib"
    "${afxSdk}/external/cuda/lib"
    "/run/opengl-driver/lib"
    "${pkgs.stdenv.cc.cc.lib}/lib"
  ];

  pipewireDeps = ["pipewire.service" "wireplumber.service" "pipewire-pulse.service"];
in {
  imports = [inputs.lan-mouse.homeManagerModules.default];

  home.packages = with pkgs;
    [
      # chromium
      fontconfig
      gimp
      dconf-editor
      # gnome-tweaks
      # jellyfin-media-player
      libreoffice-fresh
      pavucontrol
      remmina
      vlc
      # easyeffects
      spotify
      deskflow
      obsidian
      pwvucontrol
      chromium
      termscp
      ddcutil
      ddcui
      claude-desktop
      bubblewrap # cowork-mode sandbox backend for claude-desktop
    ]
    ++ lib.optionals config.my.fullDesktop [
      # handbrake
      obs-studio
      obs-studio-plugins.obs-pipewire-audio-capture
      # davinci-resolve
    ];

  systemd.user.services.echo-cancel = lib.mkIf config.my.fullDesktop {
    Unit = {
      Description = "WebRTC echo cancellation for the Yeti";
      After = pipewireDeps;
      Wants = pipewireDeps;
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStartPre = "${waitForNode} ${yetiInput}";
      ExecStart = "${pkgs.pipewire}/bin/pipewire -c ${echoCancelConf}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  systemd.user.services.afx-mic = lib.mkIf config.my.fullDesktop {
    Unit = {
      Description = "NVIDIA AFX noise removal microphone";
      After = ["echo-cancel.service"];
      Wants = ["echo-cancel.service"];
      # filter-chain unloads itself when ec_source disappears but the process
      # keeps running, so restart together instead of idling with no nodes.
      PartOf = ["graphical-session.target" "echo-cancel.service"];
      ConditionPathExists = "${afxBundle}/liblinux_broadcast_afx_ladspa.so";
    };
    Service = {
      ExecStartPre = "${waitForNode} ec_source";
      ExecStart = "${pkgs.pipewire}/bin/pipewire -c ${afxMicConf}";
      Environment = [
        "AFX_SDK_ROOT=${afxSdk}"
        "LINUX_BROADCAST_EFFECT=bnr2"
        "LINUX_BROADCAST_VAD=0"
        "LINUX_BROADCAST_FRAME_MS=10"
        "CUDA_VISIBLE_DEVICES=0"
        # The plugin shells out to nvidia-smi to pick the sm_* model.
        "PATH=/run/current-system/sw/bin"
        "LD_LIBRARY_PATH=${afxLibraryPath}"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  programs.lan-mouse.enable = false;
}
