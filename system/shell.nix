{
  lib,
  pkgs,
  ...
}: {
  programs.zsh.enable = true;
  users.users.vilsol.shell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [pkgs.nvd pkgs.nix]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["Hack"];})
  ];
}
