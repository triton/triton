# Configuration for the Name Service Switch (/etc/nsswitch.conf).

{ config, lib, pkgs, ... }:

with lib;

let

  inherit (config.services.avahi) nssmdns;
  inherit (config.services.samba) nsswins;
  ldap = config.users.ldap.enable;

in

{
  options = {

    # NSS modules.  Hacky!
    system.nssModules = mkOption {
      type = types.listOf types.path;
      internal = true;
      default = [];
      description = ''
        Search path for NSS (Name Service Switch) modules.  This allows
        several DNS resolution methods to be specified via
        <filename>/etc/nsswitch.conf</filename>.
      '';
    };

    system.nssPath = mkOption {
      type = types.path;
      internal = true;
      description = ''
        The environment containing NSS modules.
      '';
    };

  };

  config = {

    # Name Service Switch configuration file.  Required by the C
    # library.  !!! Factor out the mdns stuff.  The avahi module
    # should define an option used by this module.
    environment.etc."nsswitch.conf".text =
      ''
        passwd:    files mymachines systemd ${optionalString ldap "ldap"}
        group:     files mymachines systemd ${optionalString ldap "ldap"}
        shadow:    files ${optionalString ldap "ldap"}
        hosts:     files mymachines ${optionalString nssmdns "mdns_minimal [NOTFOUND=return]"} dns ${optionalString nssmdns "mdns"} ${optionalString nsswins "wins"} myhostname
        networks:  files
        ethers:    files
        services:  files
        protocols: files
      '';

    # Systemd provides nss-myhostname to ensure that our hostname
    # always resolves to a valid IP address.  It returns all locally
    # configured IP addresses, or ::1 and 127.0.0.2 as
    # fallbacks. Systemd also provides nss-mymachines to return IP
    # addresses of local containers.
    system.nssModules = [
      config.systemd.package
    ];

    system.nssPath = pkgs.buildEnv {
      name = "nss-path";
      paths = config.system.nssModules;
      pathsToLink = [
        "/lib"
      ];
      outputsToLink = [
        "out"
        "lib"
      ];
    };

  };
}
