{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kexec-tools
  ];

  systemd.services."prepare-kexec" = {
    description = "Preparation for kexec";
    wantedBy = [ "kexec.target" ];
    before = [ "systemd-kexec.service" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";
    path = [ pkgs.kexec-tools ];
    script = ''
      p=$(readlink -f /nix/var/nix/profiles/system)
      if ! [ -d $p ]; then exit 1; fi
      exec kexec --load $p/kernel --initrd=$p/initrd --append="$(cat $p/kernel-params) init=$p/init"
    '';
  };
}
