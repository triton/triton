{ stdenv
, fetchFromGitHub
}:

let
  version = "1.1.2";
in
stdenv.mkDerivation rec {
  name = "zstd-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "facebook";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "4cf1f70531176ac6664a36b642a6128153e3bab2cdcf691f1d8414c5c4c8e81c";
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
