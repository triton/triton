{ stdenv, fetchurl, zlib, makeWrapper, rustc }:

/* Cargo binary snapshot */

let
  snapshotDate = "2016-03-21";
in

with ((import ./common.nix) {
  inherit stdenv rustc;
  version = "snapshot-${snapshotDate}";
});

let snapshotHashes =
  if stdenv.system == "x86_64-linux" then {
    sha1 = "84266cf626ca4fcdc290bca8f1a74e6ad9e8b3d9";
    sha256 = "55ad9a8929303b4e06c18d0dd30b0d6296da784606d9c55cce98d5d7fc39a0b2";
  } else
    throw "no snapshot for platform ${stdenv.system}";

  snapshotName = "cargo-nightly-${platform}.tar.gz";
in

stdenv.mkDerivation {
  inherit name version meta passthru;

  src = fetchurl {
    url = "https://static-rust-lang-org.s3.amazonaws.com/cargo-dist/${snapshotDate}/${snapshotName}";
    sha1Confirm = snapshotHashes.sha1;
    inherit (snapshotHashes) sha256;
  };

  buildInputs = [ makeWrapper ];

  dontStrip = true;

  installPhase = ''
    mkdir -p "$out"
    ./install.sh "--prefix=$out"
    patchelf --interpreter "${stdenv.libc}/lib/${stdenv.cc.dynamicLinker}" \
             --set-rpath "${stdenv.cc.cc}/lib/:${stdenv.cc.cc}/lib64/:${zlib}/lib" \
             "$out/bin/cargo"
  '' + postInstall;
}
