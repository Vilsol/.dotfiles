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
    enableAutosuggestions = true;
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
    };
  };
}
