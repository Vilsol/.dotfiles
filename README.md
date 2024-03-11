# Vilsol dotfiles repo

## 1. Link

```bash
sudo ln -s $(pwd)/system /etc/nixos/system
```

## 2. Add machine to configuration.nix

```nix
...
  imports =
    [
      ./hardware-configuration.nix
      ./system/machines/cortex.nix
    ];
...
```