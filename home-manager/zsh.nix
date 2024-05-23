{
  programs.zsh = {
    enable = true;
    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
    '';
    historySubstringSearch = {
      enable = true;
    };
    history = {
      extended = true;
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      up = "bash " + (./. + "/../tools/up.sh");
      upgrade = "pushd /home/vilsol/.dotfiles && nix flake update && popd && up";
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
