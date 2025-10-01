{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nixos-background-updates;
  
  updateScript = pkgs.writeShellScript "nixos-background-update" ''
    set -euo pipefail
    
    # Configuration
    DOTFILES_REPO="${config.users.users.vilsol.home}/.dotfiles"
    TEMP_DIR="/tmp/nixos-background-update-$$"
    LOG_FILE="/var/log/nixos-background-updates.log"
    HOSTNAME="$(hostname)"
    
    # Logging function
    log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
    }
    
    cleanup() {
        if [[ -d "$TEMP_DIR" ]]; then
            log "Cleaning up temporary directory: $TEMP_DIR"
            rm -rf "$TEMP_DIR"
        fi
    }
    
    trap cleanup EXIT
    
    log "=== Starting background system update ==="
    log "Hostname: $HOSTNAME"
    log "Source repo: $DOTFILES_REPO"
    
    # Check if dotfiles repo exists
    if [[ ! -d "$DOTFILES_REPO" ]]; then
        log "ERROR: Dotfiles repository not found at $DOTFILES_REPO"
        exit 1
    fi
    
    # Create temporary directory and copy dotfiles
    log "Creating temporary copy of dotfiles..."
    mkdir -p "$TEMP_DIR"
    cp -r "$DOTFILES_REPO/." "$TEMP_DIR/"
    cd "$TEMP_DIR"
    
    # Update flake inputs
    log "Updating flake inputs..."
    if ! ${pkgs.nixVersions.latest}/bin/nix flake update --accept-flake-config; then
        log "ERROR: Failed to update flake inputs"
        exit 1
    fi
    
    log "Updated flake inputs. Changes:"
    if command -v ${pkgs.git}/bin/git >/dev/null 2>&1; then
        ${pkgs.git}/bin/git diff --no-index "$DOTFILES_REPO/flake.lock" "$TEMP_DIR/flake.lock" || true
    fi
    
    # Build the new system configuration
    log "Building new system configuration..."
    if ! ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake ".#$HOSTNAME" --show-trace; then
        log "ERROR: Failed to build new system configuration"
        exit 1
    fi
    
    # Create a new generation without switching
    log "Creating new boot generation..."
    if ! ${pkgs.nixos-rebuild}/bin/nixos-rebuild boot --flake ".#$HOSTNAME" --show-trace; then
        log "ERROR: Failed to create new boot generation"
        exit 1
    fi
    
    # Clean up old background-generated generations, but keep the last 3
    log "Cleaning up old background generations..."
    
    # Get current generation
    CURRENT_GEN=$(${pkgs.nixos-rebuild}/bin/nixos-rebuild list-generations | tail -n 1 | awk '{print $1}')
    log "Current generation: $CURRENT_GEN"
    
    # List all generations and remove old ones (keep current + last 2 background generations)
    GENERATIONS_TO_KEEP=3
    GENS_TO_DELETE=$(${pkgs.nixos-rebuild}/bin/nixos-rebuild list-generations | \
        grep -v "current" | \
        tail -n +$((GENERATIONS_TO_KEEP + 1)) | \
        awk '{print $1}' | \
        head -n -$GENERATIONS_TO_KEEP)
    
    if [[ -n "$GENS_TO_DELETE" ]]; then
        for gen in $GENS_TO_DELETE; do
            log "Deleting old generation: $gen"
            ${pkgs.nix}/bin/nix-env --delete-generations $gen -p /nix/var/nix/profiles/system || true
        done
        
        # Clean up the store
        log "Running garbage collection..."
        ${pkgs.nix}/bin/nix-collect-garbage || true
    else
        log "No old generations to clean up"
    fi
    
    log "=== Background system update completed successfully ==="
    log "New system generation is available for next reboot"
    log "You can switch to it immediately with: sudo nixos-rebuild switch --flake ~/.dotfiles#$HOSTNAME"
    log ""
  '';

in {
  options = {
    services.nixos-background-updates = {
      enable = mkEnableOption "automatic background NixOS system updates";
      
      time = mkOption {
        type = types.str;
        default = "05:00";
        description = "Time to run the background update (24-hour format)";
      };
      
      randomizedDelay = mkOption {
        type = types.str;
        default = "30min";
        description = "Maximum random delay before starting the update";
      };
    };
  };

  config = mkIf cfg.enable {
    # Ensure log directory exists
    systemd.tmpfiles.rules = [
      "d /var/log 0755 root root -"
      "f /var/log/nixos-background-updates.log 0644 root root -"
    ];

    # Background update service
    systemd.services.nixos-background-update = {
      description = "NixOS Background System Update";
      path = with pkgs; [ 
        nixos-rebuild 
        nix 
        git 
        gnutar 
        gzip 
        coreutils 
      ];
      
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${updateScript}";
        
        # Security settings
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ 
          "/nix/var/nix/profiles"
          "/var/log"
          "/tmp"
          "/boot"
        ];
        
        # Resource limits
        MemoryMax = "4G";
        TasksMax = 100;
        
        # Timeout settings
        TimeoutStartSec = "2h";
        
        # Restart policy
        Restart = "no";
      };
      
      # Don't start if the system was recently updated manually
      unitConfig = {
        ConditionFileNotOlderThan = "/nix/var/nix/profiles/system:1d";
      };
    };

    # Timer to run the service daily
    systemd.timers.nixos-background-update = {
      description = "Run NixOS background updates daily";
      wantedBy = [ "timers.target" ];
      
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelay;
        
        # Set specific time
        OnCalendar = "*-*-* ${cfg.time}:00";
      };
    };

    # Add a helper command for manual runs
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nixos-background-update-now" ''
        echo "Starting manual background update..."
        sudo systemctl start nixos-background-update.service
        echo "Background update started. Check logs with:"
        echo "  sudo journalctl -u nixos-background-update.service -f"
        echo "  tail -f /var/log/nixos-background-updates.log"
      '')
      
      (pkgs.writeShellScriptBin "nixos-background-update-status" ''
        echo "=== Background Update Service Status ==="
        sudo systemctl status nixos-background-update.service
        echo ""
        echo "=== Timer Status ==="
        sudo systemctl status nixos-background-update.timer
        echo ""
        echo "=== Next Scheduled Run ==="
        sudo systemctl list-timers nixos-background-update.timer
        echo ""
        echo "=== Recent Log Entries ==="
        if [[ -f /var/log/nixos-background-updates.log ]]; then
          tail -20 /var/log/nixos-background-updates.log
        else
          echo "No log file found yet."
        fi
      '')
    ];
  };
} 