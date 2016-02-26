# This module defines the packages that appear in
# /run/current-system/sw.

{ config, lib, pkgs, ... }:

with lib;

let

  requiredPackages =
    [ config.nix.package
      pkgs.acl
      pkgs.attr
      pkgs.bash
      pkgs.bzip2
      pkgs.coreutils
      pkgs.curl
      pkgs.diffutils
      pkgs.findutils
      pkgs.gawk
      pkgs.glibc # for ldd, getent
      pkgs.gnugrep
      pkgs.gnupatch
      pkgs.gnused
      pkgs.gnutar
      pkgs.gzip
      pkgs.xz
      pkgs.less
      pkgs.ncurses
      pkgs.procps
      pkgs.shadow
      pkgs.time
      pkgs.util-linux_full
    ];

in

{
  options = {

    environment = {

      systemPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        example = literalExample "[ pkgs.firefox pkgs.thunderbird ]";
        description = ''
          The set of packages that appear in
          /run/current-system/sw.  These packages are
          automatically available to all users, and are
          automatically updated every time you rebuild the system
          configuration.  (The latter is the main difference with
          installing them in the default profile,
          <filename>/nix/var/nix/profiles/default</filename>.
        '';
      };

      pathsToLink = mkOption {
        type = types.listOf types.str;
        # Note: We need `/lib' to be among `pathsToLink' for NSS modules
        # to work.
        default = [];
        example = ["/"];
        description = "List of directories to be symlinked in <filename>/run/current-system/sw</filename>.";
      };

      outputsToLink = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "doc" ];
        description = "List of package outputs to be symlinked into <filename>/run/current-system/sw</filename>.";
      };

    };

    system = {

      path = mkOption {
        internal = true;
        description = ''
          The packages you want in the boot environment.
        '';
      };

    };

  };

  config = {

    environment.systemPackages = requiredPackages;

    environment.pathsToLink = [
      "/bin"
      "/lib"
    ];

    system.path = pkgs.buildEnv {
      name = "system-path";
      paths = config.environment.systemPackages;
      inherit (config.environment) pathsToLink outputsToLink;
      ignoreCollisions = true;
    };

  };
}
