{ allPackages ? import ../../.., config, system }:

rec {

  shell = "/bin/bash";

  path = [
    "/"
    "/usr"
    "/usr/local"
  ];

  prehookBase = ''
    # Disable purity tests; it's allowed (even needed) to link to
    # libraries outside the Nix store (like the C library).
    export NIX_ENFORCE_PURITY=
  '';

  # A function that builds a "native" stdenv (one that uses tools in
  # /usr etc.).
  makeStdenv = {
    cc
    , fetchurl
    , extraPath ? [ ]
    , overrides ? (pkgs: { })
  }:

  import ../generic {
    preHook = prehookBase;

    initialPath = extraPath ++ path;

    fetchurlBoot = fetchurl;

    inherit
      system
      shell
      cc
      overrides
      config;
  };


  stdenvBoot0 = makeStdenv {
    cc = null;
    fetchurl = null;
  };


  cc = import ../../build-support/cc-wrapper {
    name = "cc-native";
    nativeTools = true;
    nativeLibc = true;
    nativePrefix = "/usr";
    stdenv = stdenvBoot0;
  };


  fetchurl = import ../../build-support/fetchurl {
    stdenv = stdenvBoot0;
    # Curl should be in /usr/bin or so.
    curl = null;
  };


  # First build a stdenv based only on tools outside the store.
  stdenvBoot1 = makeStdenv {
    inherit cc fetchurl;
  } // { inherit fetchurl; };

  stdenvBoot1Pkgs = allPackages {
    inherit system;
    bootStdenv = stdenvBoot1;
  };


  # Using that, build a stdenv that adds the ‘xz’ command (which most
  # systems don't have, so we mustn't rely on the native environment
  # providing it).
  stdenvBoot2 = makeStdenv {
    inherit cc fetchurl;
    extraPath = [ stdenvBoot1Pkgs.xz ];
    overrides = pkgs: { inherit (stdenvBoot1Pkgs) xz; };
  };


  stdenv = stdenvBoot2;
}
