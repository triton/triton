{ stdenv
, fetchFromGitHub
}:

let
  version = "1.1.1";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "811657cad50bce8c3c6aa28322f5015ec07c12c0800af32de19ec07ad44225f8";
  };

  # Makefile builds during the install phase
  preInstall = ''
    installFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
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
