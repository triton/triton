{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "zstd-${version}";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "58ff8d489a152710748048943f770eca829db4abb866ab4573923a7dcb042519";
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
