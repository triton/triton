# This module defines the software packages included in the "minimal"
# installation CD.  It might be useful elsewhere.

{ config, lib, pkgs, ... }:

{
  # Include some utilities that are useful for installing or repairing
  # the system.
  environment.systemPackages = [
    pkgs.ms-sys # for writing Microsoft boot sectors / MBRs
    pkgs.efibootmgr
    pkgs.efivar
    pkgs.gptfdisk
    pkgs.ddrescue
    pkgs.cryptsetup # needed for dm-crypt volumes

    # Hardware-related tools.
    pkgs.sdparm
    pkgs.hdparm
    pkgs.mdadm
    pkgs.smartmontools # for diagnosing hard disks
    pkgs.pciutils
    pkgs.usbutils

    # Tools for building
    pkgs.stdenv
    pkgs.git
    pkgs.mg
    pkgs.nano
    pkgs.vim

    # Misc tools
    config.programs.ssh.package
    pkgs.bind_tools
    pkgs.curl
    pkgs.htop
    pkgs.iftop
    pkgs.iotop
    pkgs.lm-sensors
    pkgs.mtr
    pkgs.nmap
    pkgs.openssl
    pkgs.gnupg
    pkgs.tmux
    pkgs.screen
    pkgs.wget
  ];

  # Include support for various filesystems.
  boot.supportedFilesystems = [
    "btrfs"
    "ext4"
    "f2fs"
    "ntfs"
    "vfat"
    "xfs"
    "zfs"
  ];

  # Configure host id for ZFS to work
  networking.hostId = lib.mkDefault "8425e349";
}
