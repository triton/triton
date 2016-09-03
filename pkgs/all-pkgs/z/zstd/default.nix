{ stdenv
, fetchFromGitHub
}:

let
  version = "0.8.1";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "08f4ba5492877a20ffd5c98d1ed5e41c6133e43ec6da5d1fe120b4b2e57caaa3";
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
