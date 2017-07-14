# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.

{ config, lib, ... }:

{
  imports =
    [ ./installation-cd-base.nix
      ../../profiles/minimal.nix
      /conf/nixos/common/base.nix
      /conf/nixos/common/sshd.nix
    ];
}
