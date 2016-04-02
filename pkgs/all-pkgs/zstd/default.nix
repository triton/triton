{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "zstd-${version}";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "935618d578b13cb004cbe057ee1b17082d81109b8b07ac896fc15756c30e5627";
  };

  # Dont do anything in the build phase since the makefile builds during install
  buildPhase = ''
    echo "Build happens during install"
  '';

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
