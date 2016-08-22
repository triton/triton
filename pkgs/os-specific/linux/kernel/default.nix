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
      version = "4.7.2";
      sha256 = "58493ee6569484fab1658e680fbb7a72ad75f02211316628fe7ee5fd39f96488";
    };
    "testing" = {
      version = "4.8-rc3";
      sha256 = "198d9d8c44a9234552ab227fe5f8a9f4b19ae6fbccb08aa2a76a6232001f3922";
    };
    "bcache" = {
      version = "4.7.2";
      owner = "wkennington";
      repo = "linux";
      rev = "9a760560cc138241faaf074a34bbc226fd433f31";
      sha256 = "66f3393c0ee0fb64758847dc17d8eb895ac26ff095a2de840611f3d09c19b483";
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
      urls = map (n: "${n}.xz") tarballUrls;
      allowHashOutput = false;
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
