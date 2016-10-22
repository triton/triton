{ stdenv
, buildLinux
, fetchFromGitHub
, fetchurl
, perl

, # Overrides to the kernel config.
  extraConfig ? ""

, # A list of patches to apply to the kernel.  Each element of this list
  # should be an attribute set {name, patch} where `name' is a
  # symbolic name and `patch' is the actual patch.  The patch may
  # optionally be compressed with gzip or bzip2.
  kernelPatches ? []

, ignoreConfigErrors ? false
, extraMeta ? {}
, channel
, ...
}:

let

  sources = {
    "4.7" = {
      version = "4.7.10";
      sha256 = "92459ba55210522ac96408c0049ca2a9a3147e7a690c70fb4b536526412b59dc";
    };
    "4.8" = {
      version = "4.8.4";
      sha256 = "c1cb8d3d912ab23b7bc689b5473828ea6cc9485f13137e9c9892a2d4d81422b0";
    };
    "testing" = {
      version = "4.9-rc1";
      sha256 = "0efb65be9189e45868062190a61467296b6eec305e8408fcffe17e20f41a22e8";
    };
    "bcache" =
      let
        date = "2016-10-20";
      in {
        version = "4.8.3";
        urls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/linux-bcachefs-${version}-${date}.tar.xz"
        ];
        sha256 = "75f42aad62c58924d84ab351569a674be8e663a4bb689f0414e28da9c87cc6be";
        features.bcachefs = true;
      };
  };

  source = sources."${channel}";

  inherit (source)
    version;

  tarballUrls = [
    "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar"
    "mirror://kernel/linux/kernel/v4.x/testing/linux-${version}.tar"
  ];

  src = if source ? rev then
    fetchFromGitHub {
      inherit (source)
        owner
        repo
        rev
        sha256;
    }
  else
    fetchurl {
      urls = source.urls or (map (n: "${n}.xz") tarballUrls);
      hashOutput = false;
      inherit (source) sha256;
    };

  srcVerification = fetchurl {
    failEarly = true;
    pgpDecompress = true;
    pgpsigUrls = map (n: "${n}.sign") tarballUrls;
    pgpKeyFingerprints = [
      "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
      "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
    ];
    inherit (src) urls outputHash outputHashAlgo;
  };

  lib = stdenv.lib;

  modDirVersion = let
    rcSplit = lib.splitString "-" version;
    vSplit = lib.splitString "." (lib.head rcSplit);
    vSplit' = if lib.length vSplit == 2 then vSplit ++ [ "0" ] else vSplit;
    rcSplit' = [ (lib.concatStringsSep "." vSplit') ] ++ lib.tail rcSplit;
  in lib.concatStringsSep "-" rcSplit';

  common = import ./common.nix { inherit stdenv; };

  kernelConfigFun = baseConfig:
    let
      configFromPatches =
        map ({extraConfig ? "", ...}: extraConfig) kernelPatches;
    in lib.concatStringsSep "\n" ([baseConfig] ++ configFromPatches);

  configfile = stdenv.mkDerivation {
    inherit ignoreConfigErrors;
    name = "linux-config-${version}";

    generateConfig = ./generate-config.pl;

    kernelConfig = kernelConfigFun config;

    nativeBuildInputs = [ perl ];

    platformName = "pc";
    kernelBaseConfig = "defconfig";
    kernelTarget = "bzImage";
    autoModules = true;
    arch = common.kernelArch;

    prePatch = kernel.prePatch + ''
      # Patch kconfig to print "###" after every question so that
      # generate-config.pl from the generic builder can answer them.
      sed -e '/fflush(stdout);/i\printf("###");' -i scripts/kconfig/conf.c
    '';

    inherit (kernel) src patches preUnpack;

    buildPhase = ''
      cd $buildRoot

      # Get a basic config file for later refinement with $generateConfig.
      make -C ../$sourceRoot O=$PWD $kernelBaseConfig ARCH=$arch

      # Create the config file.
      echo "generating kernel configuration..."
      echo "$kernelConfig" > kernel-config
      DEBUG=1 ARCH=$arch KERNEL_CONFIG=kernel-config AUTO_MODULES=$autoModules \
           SRC=../$sourceRoot perl -w $generateConfig
    '';

    installPhase = "mv .config $out";
  };

  kernel = buildLinux {
    inherit version modDirVersion src kernelPatches;

    configfile = configfile.nativeDrv or configfile;

    crossConfigfile = configfile.crossDrv or configfile;

    config = { CONFIG_MODULES = "y"; CONFIG_FW_LOADER = "m"; };

    crossConfig = { CONFIG_MODULES = "y"; CONFIG_FW_LOADER = "m"; };
  };

  passthru = {
    meta = kernel.meta // extraMeta;

    inherit srcVerification;

    features = source.features or { };

    passthru = kernel.passthru // (removeAttrs passthru [ "passthru" "meta" ]);
  };

  config = import ./common-config.nix
    { inherit stdenv version extraConfig; };

  nativeDrv = lib.addPassthru kernel.nativeDrv passthru;

  crossDrv = lib.addPassthru kernel.crossDrv passthru;
in if kernel ? crossDrv then nativeDrv // { inherit nativeDrv crossDrv; } else lib.addPassthru kernel passthru
