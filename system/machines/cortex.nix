{
  imports = [
    ../default.nix
    ../nvidia.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
