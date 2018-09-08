{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    boolEn;

  version = "0.1";
in
stdenv.mkDerivation rec {
  name = "textencode-${version}";

  src = fetchurl {
    url = "https://github.com/triton/textencode/releases/download/v${version}/${name}.tar.xz";
    multihash = "QmWsThAGsQYUoo3foaAKWvLR8f76KnMwjEdN4t4xL46C7x";
    sha256 = "d3c47856f44a1c92f868223874c73da6ce6fdffe213fbf7297b6d77addb6f455";
  };

  configureFlags = [
    "--${boolEn doCheck}-tests"
  ];

  doCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
