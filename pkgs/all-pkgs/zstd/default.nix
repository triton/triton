{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "zstd-${version}";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "2e1b18e4b07c685748304f7306dfa9468dc1cc9a052e733c95d44febbf0510ce";
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
