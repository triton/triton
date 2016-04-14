{ stdenv
, fetchgit
, rustPlatform
, file
, curl
, python
, pkgconfig
, openssl
, cmake
, zlib
, makeWrapper
}:

with rustPlatform;

with ((import ./common.nix) {
  inherit stdenv rustc;
  version = "0.10.0";
});

buildRustPackage rec {
  inherit name version meta passthru;

  # Needs to use fetchgit instead of fetchFromGitHub to fetch submodules
  src = fetchgit {
    url = "git://github.com/rust-lang/cargo";
    rev = "refs/tags/${version}";
    sha256 = "14ra0sbh9srxnbdgccnmra56n8ccrmgdvb4s964gny493c0gva2r";
  };

  depsSha256 = "0js4697n7v93wnqnpvamhp446w58llj66za5hkd6wannmc0gsy3b";

  buildInputs = [ file curl pkgconfig python openssl cmake zlib makeWrapper ];

  configurePhase = ''
    ./configure --enable-optimize --prefix=$out --local-cargo=${cargo}/bin/cargo
  '';

  buildPhase = "make";

  # Disable check phase as there are lots of failures (some probably due to
  # trying to access the network).
  doCheck = false;

  installPhase = ''
    make install
    ${postInstall}
  '';
}
