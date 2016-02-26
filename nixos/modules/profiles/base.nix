# This module defines the software packages included in the "minimal"
# installation CD.  It might be useful elsewhere.

{ config, lib, pkgs, ... }:

{
  # Include some utilities that are useful for installing or repairing
  # the system.
  environment.systemPackages = [
    pkgs.mssys # for writing Microsoft boot sectors / MBRs
    pkgs.efibootmgr
    pkgs.efivar
    pkgs.gptfdisk
    pkgs.ddrescue
    pkgs.openssl
    pkgs.cryptsetup # needed for dm-crypt volumes

    # Hardware-related tools.
    pkgs.sdparm
    pkgs.hdparm
    pkgs.mdadm
    pkgs.smartmontools # for diagnosing hard disks
    pkgs.pciutils
    pkgs.usbutils

    # Tools to create / manipulate filesystems.
    pkgs.ntfsprogs # for resizing NTFS partitions
    pkgs.dosfstools
    pkgs.xfsprogs
    pkgs.f2fs-tools
  ];

  # Include support for various filesystems.
  boot.supportedFilesystems = [ "btrfs" "vfat" "f2fs" "xfs" "zfs" "ntfs" ];

  # Configure host id for ZFS to work
  networking.hostId = lib.mkDefault "8425e349";
}
