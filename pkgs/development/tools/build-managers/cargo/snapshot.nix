{ stdenv, fetchurl, zlib, makeWrapper, rustc }:

/* Cargo binary snapshot */

let
  snapshotDate = "2016-01-31";
in

with ((import ./common.nix) {
  inherit stdenv rustc;
  version = "snapshot-${snapshotDate}";
});

let snapshotHashes =
  if stdenv.system == "x86_64-linux" then {
    sha1 = "4c03a3fd2474133c7ad6d8bb5f6af9915ca5292a";
    sha256 = "19jzx889bi21kq8mm33xysq0pcigsshh8rzzcfkyndmmp9hyc80r";
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
