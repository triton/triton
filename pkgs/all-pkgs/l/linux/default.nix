{ stdenv
, buildLinux
, fetchFromGitHub
, fetchurl
, git
, lib
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
      version = "4.9.73";
      baseSha256 = "029098dcffab74875e086ae970e3828456838da6e0ba22ce3f64ef764f3d7f1a";
      patchSha256 = "2af9c1806d1c4a6b90f5b105bdb6eedba8e0610712d0bab8a906bb015b2993f3";
    };
    "4.13" = {
      version = "4.13.16";
      baseSha256 = "2db3d6066c3ad93eb25b973a3d2951e022a7e975ee2fa7cbe5bddf84d9a49a2c";
      patchSha256 = "f24980db582b9b3d3ded4c96b16f8c64bc435fca59b91cf3f224611b68216d8a";
    };
    "4.14" = {
      version = "4.14.10";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchSha256 = "16f560aa713b46c707f04a226f67dc31fdd280aae57dd19e0413d61df5336c74";
    };
    "testing" = {
      version = "4.15-rc4";
      baseSha256 = "f81d59477e90a130857ce18dc02f4fbe5725854911db1e7ba770c7cd350f96a7";
      patchUrls = [
        "https://github.com/wkennington/linux/releases/download/v${version}/patch-${version}.xz"
      ];
      patchSha256 = "ff3c0eb4a8f3b3a3079713d56bae436f09c5696407ea48b2d296ca1a890eda50";
    };
    "bcachefs" =
      let
        date = "2017-12-24";
      in {
        version = "4.13.16";
        patchUrls = [
          "https://github.com/wkennington/linux/releases/download/bcachefs-${version}-${date}/patch-bcachefs-${version}-${date}.xz"
        ];
        baseSha256 = "2db3d6066c3ad93eb25b973a3d2951e022a7e975ee2fa7cbe5bddf84d9a49a2c";
        patchSha256 = "463739463795d95aeba83ccee4154ec801f43a9c880e697494dfc0b00a5efcdf";
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
