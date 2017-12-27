{ stdenv
, fetchFromGitHub
, lib

, lz4
, xz
, zlib
}:

let
  version = "1.3.3";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "8b72e1fa00ce3948058a7b969fb51b230ea220be4e9f6c42ddc2094a27603385";
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
