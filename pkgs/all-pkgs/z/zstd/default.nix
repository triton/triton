{ stdenv
, fetchFromGitHub
, lib

, lz4
, xz
, zlib
}:

let
  version = "1.3.2";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "2159b6e01f9dabd84f09e8e722f7a49575e9e4a41d57a495e9867d67b3befa3f";
  };

  buildInputs = [
    lz4
    xz
    zlib
  ];

  # Makefile builds during the install phase
  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    description = "Fast real-time lossless compression algorithm";
    homepage = http://www.zstd.net/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
