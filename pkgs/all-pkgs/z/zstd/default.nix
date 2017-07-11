{ stdenv
, fetchFromGitHub
, lib

, xz
, zlib
}:

let
  version = "1.3.0";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "3b7e4966b77dc7ae13bf328c880691468612f41e66725c9286af5bf73b9a10d1";
  };

  buildInputs = [
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
