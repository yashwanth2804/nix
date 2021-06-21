#!/usr/bin/env bash

# Regression test for https://github.com/NixOS/nix/issues/4858

source common.sh
sed -i 's/experimental-features .*/& ca-derivations ca-references/' "$NIX_CONF_DIR"/nix.conf

# Get the output path of `rootCA`, and put some garbage instead
outPath="$(nix-build ./content-addressed.nix -A rootCA --no-out-link)"
nix-store --delete "$outPath"
touch "$outPath"

# The build should correctly remove the garbage and put the expected path instead
nix-build ./content-addressed.nix -A rootCA --no-out-link

# Rebuild it. This shouldn’t overwrite the existing path
oldInode=$(stat -c '%i' "$outPath")
nix-build ./content-addressed.nix -A rootCA --no-out-link --arg seed 2
newInode=$(stat -c '%i' "$outPath")
[[ "$oldInode" == "$newInode" ]]
