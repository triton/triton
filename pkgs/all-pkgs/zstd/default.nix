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
    sha256 = "eea47f1875b3e8d30dd96cdf2c41e076a9d40032bb1eeeb6edf5e14b4f0b962d";
  };

  doConfigure = false;

  doBuild = false;

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
