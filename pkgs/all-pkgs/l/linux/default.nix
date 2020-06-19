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
    "4.19" = {
      version = "4.19.124";
      baseSha256 = "0c68f5655528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1";
      patchSha256 = "3f0f43ca3cb4eba7441d57cd3f9bb3d27721f8ffcef2d64469faaff2846f7f95";
    };
    "5.4" = {
      version = "5.4.42";
      baseSha256 = "bf338980b1670bca287f9994b7441c2361907635879169c64ae78364efc5f491";
      patchSha256 = "c01da2932dd8c04965760ca674abf8f150d456553bc9148bee1823f4c48a39d2";
    };
    "5.6" = {
      version = "5.6.14";
      baseSha256 = "e342b04a2aa63808ea0ef1baab28fc520bd031ef8cf93d9ee4a31d4058fcb622";
      patchSha256 = "07e737cfdc79382dc259c4844a150d8d72ebbcdc9d7e03a9503f8f8e19f1aea4";
    };
    "testing" = {
      version = "5.7-rc7";
      baseSha256 = "e342b04a2aa63808ea0ef1baab28fc520bd031ef8cf93d9ee4a31d4058fcb622";
      patchUrls = [
        "https://github.com/wkennington/linux/releases/download/v${version}/patch-${version}.xz"
      ];
      patchSha256 = "8fb81ec01f60ed8c6d91a20c4e30eef2738770721504638c28ce2f48c9453728";
    };
    "bcachefs" =
      let
        date = "2019-06-22";
      in {
        version = "5.1.14";
        patchUrls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/patch-bcachefs-${version}-${date}.xz"
        ];
        baseSha256 = "d06a7be6e73f97d1350677ad3bae0ce7daecb79c2c2902aaabe806f7fa94f041";
        patchSha256 = "65f99e67a5991876179b43439c92eefc5d4206646ea844109db4a47534cebd07";
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
