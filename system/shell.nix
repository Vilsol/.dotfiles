{pkgs, ...}: {
  programs.zsh.enable = true;
  users.users.vilsol.shell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["Hack"];})
  ];
}
