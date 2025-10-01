{
  programs.zsh = {
    enable = true;
    initContent = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      eval "$(mise activate zsh)"
    '';
    historySubstringSearch = {
      enable = true;
    };
    history = {
      extended = true;
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      # up = "bash " + (./. + "/../tools/up.sh");
      # upgrade = "pushd /home/vilsol/.dotfiles && nix flake update && popd && up";
      up = "nh os switch ~/.dotfiles -v --ask";
      upb = "nh os boot ~/.dotfiles -v --ask";
      upgrade = "nh os switch ~/.dotfiles -v --ask -u";
      upgradeb = "nh os boot ~/.dotfiles -v --ask -u";
    };
    oh-my-zsh = {
      enable = true;
    };
    autosuggestion.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      right_format = "$cmd_duration$time";
      kubernetes = {
        format = "[⛵($cluster)](dimmed green) ";
        disabled = false;
      };
      sudo = {
        style = "bold green";
        symbol = "💻 ";
        disabled = false;
      };
      time = {
        format = "[\\[$time\\]]($style) ";
        time_format = "%T";
        disabled = false;
      };
      line_break = {
        disabled = true;
      };
      cmd_duration = {
        min_time = 0;
        show_milliseconds = true;
      };
    };
  };
}
