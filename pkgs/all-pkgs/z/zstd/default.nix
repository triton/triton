{ stdenv
, fetchFromGitHub
, lib

, xz
, zlib
}:

let
  version = "1.2.0";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "d9b1d70ec10723d8af88d88c728ea28d41f984215a4d4aac6812a3e2be6703ed";
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
