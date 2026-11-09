# Claude Code and everything it starts run in claude.slice, a sibling of app.slice, so a low CPUWeight makes it yield
# to games and a memory ceiling keeps it off the desktop. `claude-cap` changes the limits live; `capped` runs a heavy
# command in claude-heavy.slice (nested under claude.slice) with its own memory cap.
{pkgs, ...}: let
  claude-cap = pkgs.writeShellApplication {
    name = "claude-cap";
    runtimeInputs = with pkgs; [systemd coreutils gawk findutils];
    text = ''
      slice=claude.slice
      dir=/sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/$slice

      set_() { systemctl --user set-property --runtime "$slice" "$@"; }

      status() {
        if [[ ! -d $dir ]]; then
          echo "claude.slice is not running (start claude from a new shell)"
          return
        fi
        read -r q p <"$dir/cpu.max"
        if [[ $q == max ]]; then quota=none; else quota=$(awk -v q="$q" -v p="$p" 'BEGIN{printf "%g cores", q/p}'); fi
        u1=$(awk '/^usage_usec/{print $2}' "$dir/cpu.stat")
        sleep 1
        u2=$(awk '/^usage_usec/{print $2}' "$dir/cpu.stat")
        used=$(awk -v a="$u1" -v b="$u2" 'BEGIN{printf "%.1f", (b-a)/1e6}')
        mem=$(awk '{printf "%.1fG", $1/1073741824}' "$dir/memory.current")
        memmax=$(awk '{ if ($1=="max") print "none"; else printf "%gG", $1/1073741824 }' "$dir/memory.max")
        procs=$(find "$dir" -name cgroup.procs -exec cat {} + | wc -l)
        echo "claude.slice  weight $(cat "$dir/cpu.weight")  cpu cap $quota  using $used cores  mem $mem / $memmax  $procs procs"
      }

      usage() {
        cat <<EOF
      usage: claude-cap [status]   show limits and current use
             claude-cap <n>        hard cap at n cores
             claude-cap off        remove the cpu cap (weight unchanged)
             claude-cap game       weight 5, cap 6 cores
             claude-cap normal     weight 20, no cpu cap
             claude-cap mem <size> memory ceiling, e.g. 32G (the slice default comes back at reboot)
      EOF
      }

      case ''${1:-status} in
      status) status ;;
      off) set_ CPUQuota= ;;
      normal) set_ CPUWeight=20 CPUQuota= ;;
      game) set_ CPUWeight=5 CPUQuota=600% ;;
      mem) set_ MemoryMax="''${2:?size, e.g. 32G}" ;;
      -h | --help | help) usage ;;
      *)
        if [[ $1 =~ ^[0-9]+$ ]]; then set_ CPUQuota="$(($1 * 100))%"; else
          usage >&2
          exit 2
        fi
        ;;
      esac
    '';
  };

  capped = pkgs.writeShellApplication {
    name = "capped";
    runtimeInputs = [pkgs.systemd pkgs.coreutils];
    text = ''
      mem=''${1:-}
      if [[ ! $mem =~ ^[0-9]+[KMGT]$ ]] || [[ $# -lt 2 ]]; then
        echo "usage: capped <memory, e.g. 8G> <command...>" >&2
        exit 2
      fi
      shift
      exec systemd-run --user --scope --slice=claude-heavy.slice --collect -q \
        -p MemoryMax="$mem" -p MemorySwapMax=0 nice -n 10 "$@"
    '';
  };
in {
  home.packages = [claude-cap capped];

  systemd.user.slices.claude = {
    Unit.Description = "Claude Code and everything it starts";
    Slice = {
      CPUWeight = 20;
      MemoryHigh = "36G";
      MemoryMax = "40G";
      MemorySwapMax = 0;
    };
  };

  # Start claude inside claude.slice; a claude already inside it (a nested shell) runs as is.
  programs.zsh.initContent = ''
    claude() {
      if grep -q '/claude\.slice/' /proc/self/cgroup; then
        command claude "$@"
      else
        systemd-run --user --scope --slice=claude.slice --collect -q -- claude "$@"
      fi
    }
  '';

  # gamemode reads this per-user file as well as /etc/gamemode.ini.
  xdg.configFile."gamemode.ini".text = ''
    [custom]
    start=${claude-cap}/bin/claude-cap game
    end=${claude-cap}/bin/claude-cap normal
  '';
}
