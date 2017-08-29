{ stdenv
, fetchFromGitHub
, lib

, lz4
, xz
, zlib
}:

let
  version = "1.3.1";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "61bbd7cab9d9b7a1f94d2122ca9496236ece5c0739fa02ba48dc7449ff3a4e16";
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
