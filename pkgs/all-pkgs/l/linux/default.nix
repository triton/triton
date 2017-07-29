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
      version = "4.9.40";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "8e85a7e9de8fcc2f06f8539b743de30e2ba1f5b9e6784da0701c3ab2b896f019";
    };
    "4.11" = {
      version = "4.11.12";
      baseSha256 = "b67ecafd0a42b3383bf4d82f0850cbff92a7e72a215a6d02f42ddbafcf42a7d6";
      patchSha256 = "707c5f18dfb795761b0b7ac6f946f03774f9f99317306fd54d8724d17d9c7729";
    };
    "4.12" = {
      version = "4.12.4";
      baseSha256 = "a45c3becd4d08ce411c14628a949d08e2433d8cdeca92036c7013980e93858ab";
      patchSha256 = "7cabddeaba0f9bd85278254ddd6e8af883539df70ec0ed1bda18ce83f57b304a";
    };
    "testing" = {
      version = "4.13-rc2";
      baseSha256 = "a45c3becd4d08ce411c14628a949d08e2433d8cdeca92036c7013980e93858ab";
      patchUrls = [
        "https://github.com/wkennington/linux/releases/download/v${version}/patch-${version}.xz"
      ];
      patchSha256 = "3950ec9e567a28b21095e6724bc6d2110b3f98e62a1e3f92f212552d1d553a5d";
    };
    "bcachefs" =
      let
        date = "2017-06-12";
      in {
        version = "4.11.4";
        patchUrls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/patch-bcachefs-${version}-${date}.xz"
        ];
        baseSha256 = "b67ecafd0a42b3383bf4d82f0850cbff92a7e72a215a6d02f42ddbafcf42a7d6";
        patchSha256 = "fda8dadeae3ff83377beb18f7eb47a5ea7be6a6f9953a0162f348c5867a1b740";
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

    inherit channel srcsVerification;

    features = source.features or { };

    passthru = kernel.passthru // (removeAttrs passthru [ "passthru" "meta" ]);
  };

  config = import ./common-config.nix
    { inherit stdenv version extraConfig; };

  nativeDrv = lib.addPassthru kernel.nativeDrv passthru;

  crossDrv = lib.addPassthru kernel.crossDrv passthru;
in if kernel ? crossDrv then nativeDrv // { inherit nativeDrv crossDrv; } else lib.addPassthru kernel passthru
