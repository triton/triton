{ stdenv
, buildLinux
, fetchFromGitHub
, fetchurl
, git
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
    "4.9" = {
      version = "4.9.18";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "a645964a5fa458cc989f329f330810affbcfdf6fbee0ab44f65c4c07eb8bfc00";
    };
    "4.10" = {
      version = "4.10.5";
      baseSha256 = "3c95d9f049bd085e5c346d2c77f063b8425f191460fcd3ae9fe7e94e0477dc4b";
      patchSha256 = "03c64409653b19d39af54c8781fde0a3747ba16577c9e5b0e1031e5d8fc29db6";
    };
    "testing" = {
      version = "4.11-rc3";
      baseSha256 = "3c95d9f049bd085e5c346d2c77f063b8425f191460fcd3ae9fe7e94e0477dc4b";
      patchSha256 = "42bc915a0fec22541716a32167dab53f8f3417e31be33588820985b0a791382e";
    };
    "bcachefs" =
      let
        date = "2017-03-22";
      in {
        version = "4.9.17";
        patchUrls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/patch-bcachefs-${version}-${date}.xz"
        ];
        baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
        patchSha256 = "c47eecf3eb0bcf328f2af53370867759f454262225e34e8c41e2789f86a0a768";
        features.bcachefs = true;
      };
  };

  source = sources."${channel}";

  inherit (source)
    version;

  inherit (stdenv.lib)
    elemAt
    head
    optionals
    splitString
    tail
    toInt;

  needsGitPatch = source.needsGitPatch or false;

  unpatchedVersion =
    let
      rclist = splitString "-" version;
      isRC = [ ] != tail rclist;
      vlist = splitString "." (head rclist);
      minorInt = toInt (elemAt vlist 1);
      correctMinor = if isRC then minorInt - 1 else minorInt;
    in "${elemAt vlist 0}.${toString correctMinor}";

  directoryUrls = [
    "mirror://kernel/linux/kernel/v4.x"
    "mirror://kernel/linux/kernel/v4.x/testing"
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
      urls =
        let
          version' = if source ? baseSha256 then unpatchedVersion else version;
        in source.baseUrls or (source.urls or (map (n: "${n}/linux-${version'}.tar.xz") directoryUrls));
      hashOutput = false;
      sha256 = source.baseSha256 or source.sha256;
    };

  patch = if source ? patchSha256 && source.patchSha256 != null then
    fetchurl {
      urls = source.patchUrls or (map (n: "${n}/patch-${version}.xz") directoryUrls);
      hashOutput = false;
      sha256 = source.patchSha256;
    }
  else
    null;

  srcsVerification = [
    (fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}/linux-${if source ? baseSha256 then unpatchedVersion else version}.tar.sign") directoryUrls;
      pgpKeyFingerprints = [
        "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
        "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    })
  ] ++ optionals (patch != null) [
    (fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}/patch-${version}.sign") directoryUrls;
      pgpKeyFingerprints = [
        "647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E"
        "ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886"
      ];
      inherit (patch) urls outputHash outputHashAlgo;
    })
  ];

  lib = stdenv.lib;

  modDirVersion = let
    rcSplit = lib.splitString "-" version;
    vSplit = lib.splitString "." (lib.head rcSplit);
    vSplit' = if lib.length vSplit == 2 then vSplit ++ [ "0" ] else vSplit;
    rcSplit' = [ (lib.concatStringsSep "." vSplit') ] ++ tail rcSplit;
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

    nativeBuildInputs = [ perl ]
      ++ optionals needsGitPatch [ git ];

    platformName = "pc";
    kernelBaseConfig = "defconfig";
    kernelTarget = "bzImage";
    autoModules = true;
    arch = common.kernelArch;

    postPatch = kernel.postPatch + ''
      # Patch kconfig to print "###" after every question so that
      # generate-config.pl from the generic builder can answer them.
      sed -e '/fflush(stdout);/i\printf("###");' -i scripts/kconfig/conf.c
    '';

    inherit (kernel) src patches preUnpack prePatch;

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
    inherit version modDirVersion src needsGitPatch patch kernelPatches;

    configfile = configfile.nativeDrv or configfile;

    crossConfigfile = configfile.crossDrv or configfile;

    config = { CONFIG_MODULES = "y"; CONFIG_FW_LOADER = "m"; };

    crossConfig = { CONFIG_MODULES = "y"; CONFIG_FW_LOADER = "m"; };
  };

  passthru = {
    meta = kernel.meta // extraMeta;

    inherit srcsVerification;

    features = source.features or { };

    passthru = kernel.passthru // (removeAttrs passthru [ "passthru" "meta" ]);
  };

  config = import ./common-config.nix
    { inherit stdenv version extraConfig; };

  nativeDrv = lib.addPassthru kernel.nativeDrv passthru;

  crossDrv = lib.addPassthru kernel.crossDrv passthru;
in if kernel ? crossDrv then nativeDrv // { inherit nativeDrv crossDrv; } else lib.addPassthru kernel passthru
