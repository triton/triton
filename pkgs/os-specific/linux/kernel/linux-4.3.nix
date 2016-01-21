{ stdenv, fetchurl, perl, buildLinux, ... } @ args:

import ./generic.nix (args // rec {
  version = "4.3.3";
  extraMeta.branch = "4.3";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
    sha256 = "1kx3piydaxm7hp4f14qw0z9z11dzg3a4p15h870frhj9s3klrbcc";
  };

  kernelPatches = args.kernelPatches ++ [ { name = "cve-2016-0728"; patch = ./cve-2016-0728.patch; } ];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = true;
  features.canDisableNetfilterConntrackHelpers = true;
  features.netfilterRPFilter = true;
} // (args.argsOverride or {}))
