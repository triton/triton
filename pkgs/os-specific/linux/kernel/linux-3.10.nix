{ stdenv, fetchurl, perl, buildLinux, ... } @ args:

import ./generic.nix (args // rec {
  version = "3.10.95";
  extraMeta.branch = "3.10";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v3.x/linux-${version}.tar.xz";
    sha256 = "09mxi7v6cljb9gaav8y3xvn2c7scr1l1lrsab1r5gnkv2gb8cs7m";
  };

  kernelPatches = args.kernelPatches ++ [ { name = "cve-2016-0728"; patch = ./cve-2016-0728.patch; } ];

  features.iwlwifi = true;
  features.efiBootStub = true;
  features.needsCifsUtils = true;
  features.canDisableNetfilterConntrackHelpers = true;
  features.netfilterRPFilter = true;
})
