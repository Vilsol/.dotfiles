#!/usr/bin/env bash

tmpdir=$(mktemp -d)

nix --extra-experimental-features nix-command build /home/vilsol/.dotfiles#nixosConfigurations."$(hostname)".config.system.build.toplevel --verbose --out-link "$tmpdir/result"

if [[ "$?" != "0" ]]; then
    exit 1
fi

nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) "$tmpdir/result"

rm -rf $tmpdir

read -p "Switch to new config [Y/n]: " confirmation

if [[ "$confirmation" = "" || "$confirmation" = "Y" || "$confirmation" = "y" ]]; then
    sudo echo ""
    sudo nixos-rebuild switch
fi