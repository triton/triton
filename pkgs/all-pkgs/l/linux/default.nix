{ stdenv
, bison
, buildLinux
, fetchFromGitHub
, fetchurl
, flex
, git
, lib
, perl

, gmp
, mpfr
, libmpc

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
    "4.14" = {
      version = "4.14.102";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchSha256 = "d9b5692772b0f9100e586def851ec59b493bd3206d9f149745d933346326ea4e";
    };
    "4.19" = {
      version = "4.19.24";
      baseSha256 = "0c68f5655528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1";
      patchSha256 = "4324cf539ac734fe857076a02687657b71802d85352f04530074597f92f1d1a7";
    };
    "4.20" = {
      version = "4.20.11";
      baseSha256 = "ad0823183522e743972382df0aa08fb5ae3077f662b125f1e599b0b2aaa12438";
      patchSha256 = "35157d905f8d488af632f29a7b0a120cb377d7a7c011cd4e66c6428346d9c5b2";
    };
    "testing" = {
      version = "5.0-rc7";
      baseSha256 = "ad0823183522e743972382df0aa08fb5ae3077f662b125f1e599b0b2aaa12438";
      patchUrls = [
        "https://github.com/wkennington/linux/releases/download/v${version}/patch-${version}.xz"
      ];
      patchSha256 = "40f98d588ae73a5af6e9f12e07fbd7ca9593b1d197705c2342022181c7ffe4c4";
    };
    "bcachefs" =
      let
        date = "2019-02-13";
      in {
        version = "4.20.8";
        patchUrls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/patch-bcachefs-${version}-${date}.xz"
        ];
        baseSha256 = "ad0823183522e743972382df0aa08fb5ae3077f662b125f1e599b0b2aaa12438";
        patchSha256 = "1bd8f39aef903f35b9ee9ab40fef3a37a84158f857505eb99d081d7c56dbaf1b";
        features.bcachefs = true;
      };
  };

  source = sources."${channel}";

  inherit (source)
    version;

  inherit (import ./source.nix { inherit lib fetchurl fetchFromGitHub source; })
    src
    srcsVerification
    patch;

  inherit (builtins)
    substring;

  inherit (lib)
    addPassthru
    any
    concatStringsSep
    head
    length
    optionals
    splitString
    tail
    versionAtLeast
    versionOlder;

  needsGitPatch = source.needsGitPatch or false;

  modDirVersion = let
    rcSplit = splitString "-" version;
    vSplit = splitString "." (head rcSplit);
    vSplit' = if length vSplit == 2 then vSplit ++ [ "0" ] else vSplit;
    rcSplit' = [ (concatStringsSep "." vSplit') ] ++ tail rcSplit;
  in concatStringsSep "-" rcSplit';

  common = import ./common.nix { inherit stdenv; };

  kernelConfigFun = baseConfig:
    let
      configFromPatches =
        map ({extraConfig ? "", ...}: extraConfig) kernelPatches;
    in concatStringsSep "\n" ([baseConfig] ++ configFromPatches);

  configfile = stdenv.mkDerivation {
    inherit ignoreConfigErrors;
    name = "linux-config-${version}";

    generateConfig = ./generate-config.pl;

    kernelConfig = kernelConfigFun config;

    nativeBuildInputs = [ perl ]
      ++ optionals needsGitPatch [ git ]
      ++ optionals (versionAtLeast version "4.16") [ bison flex ];

    # Referenced by gcc internally for plugins
    buildInputs = optionals (versionAtLeast version "4.9") [ gmp mpfr libmpc ];

    platformName = "pc";
    kernelBaseConfig = "defconfig";
    kernelTarget = "bzImage";
    autoModules = true;
    arch = common.kernelArch;

    # We don't want these compiler security features / optimizations
    optFlags = false;
    pie = false;
    fpic = false;
    noStrictOverflow = false;
    fortifySource = false;
    stackProtector = false;
    optimize = false;

    postPatch = kernel.postPatch + ''
      # Patch kconfig to print "###" after every question so that
      # generate-config.pl from the generic builder can answer them.
      sed -e '/fflush(stdout);/i\printf("###");' -i scripts/kconfig/conf.c
    '';

    inherit (kernel) src patches preUnpack prePatch;

    buildPhase = ''
      cd $buildRoot

      # Get a basic config file for later refinement with $generateConfig.
      make -C ../$srcRoot O=$PWD $kernelBaseConfig ARCH=$arch

      # Create the config file.
      echo "generating kernel configuration..."
      echo "$kernelConfig" > kernel-config
      DEBUG=1 ARCH=$arch KERNEL_CONFIG=kernel-config AUTO_MODULES=$autoModules \
           SRC=../$srcRoot perl -w $generateConfig
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

  passthru = rec {
    meta = kernel.meta // extraMeta;

    inherit channel srcsVerification;

    # Return Major.Minor version string.
    channelVersion =
      let
        kv = source.version;
      in
      if any (n: n == (substring 3 1 kv)) [ "." "-" "" ] then
        substring 0 3 kv
      else if any (n: n == (substring 4 1 kv)) [ "." "-" "" ] then
        substring 0 4 kv
      else
        throw "linux.channelVersion: Unsupported kernel version string `${kv}`";

    features = source.features or { };

    # Returns false if channelVerison is greater than maxv or lessthan minv.
    isCompatibleVersion = maxv: minv:
      let
        cv = channelVersion;
      in
      if cv == maxv || (versionOlder cv maxv && versionAtLeast cv minv) then
        true
      else
        false;

    passthru = kernel.passthru // (removeAttrs passthru [ "passthru" "meta" ]);
  };

  config = import ./common-config.nix
    { inherit stdenv version extraConfig; };

  nativeDrv = addPassthru kernel.nativeDrv passthru;

  crossDrv = addPassthru kernel.crossDrv passthru;
in if kernel ? crossDrv then nativeDrv // { inherit nativeDrv crossDrv; } else addPassthru kernel passthru
