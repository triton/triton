# Provide a basic configuration for installation devices like CDs.
{ config, pkgs, lib, ... }:

with lib;

{
  imports =
    [ # Enable devices which are usually scanned, because we don't know the
      # target system.
      ../installer/scan/detected.nix
      ../installer/scan/not-detected.nix

      # Allow "nixos-rebuild" to work properly by providing
      # /etc/nixos/configuration.nix.
      ./clone-config.nix

      # Include a copy of Nixpkgs so that nixos-install works out of
      # the box.
      # TODO: Re-enable when we have a real channel
      #../installer/cd-dvd/channel.nix
    ];

  config = {

    # Automatically log in at the virtual consoles.
    services.mingetty.autologinUser = "root";

    # Some more help text.
    services.mingetty.helpLine =
      ''

        The "root" account has an empty password.  ${
          optionalString config.services.xserver.enable
            "Type `start display-manager' to\nstart the graphical user interface."}
      '';

    # It's nice to have gpm by default since we have the binary anyway
    services.gpm.enable = true;

    # Allow dhcpcd to be started manually through start dhcpcd
    networking.useDHCP = lib.mkDefault true;
    systemd.services.dhcpcd.wantedBy = lib.mkOverride 50 [];

    # Allow sshd to be started manually through "start sshd".
    services.openssh.enable = true;
    systemd.services.sshd.wantedBy = mkOverride 50 [];

    # Allow ntp to be enabled via chrony
    services.chrony.enable = true;
    services.chrony.initstepslew.enable = true;
    systemd.services.chrony.wantedBy = mkOverride 50 [];

    # Enable wpa_supplicant, but don't start it by default.
    networking.wireless.enable = mkDefault true;
    systemd.services.wpa_supplicant.wantedBy = mkOverride 50 [];

    # Tell the Nix evaluator to garbage collect more aggressively.
    # This is desirable in memory-constrained environments that don't
    # (yet) have swap set up.
    environment.variables.GC_INITIAL_HEAP_SIZE = "100000";

    # Make the installer more likely to succeed in low memory
    # environments.  The kernel's overcommit heustistics bite us
    # fairly often, preventing processes such as nix-worker or
    # download-using-manifests.pl from forking even if there is
    # plenty of free memory.
    boot.kernel.sysctl."vm.overcommit_memory" = "1";

    # To speed up installation a little bit, include the complete
    # stdenv in the Nix store on the CD.  Archive::Cpio is needed for
    # the initrd builder.
    system.extraDependencies = with pkgs; [
      stdenv
      busybox
      perlPackages.ArchiveCpio
    ];

  };
}
