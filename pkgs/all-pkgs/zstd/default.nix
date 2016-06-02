{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "zstd-${version}";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "zstd";
    rev = "v${version}";
    sha256 = "afb6e5b3f61066eee730573c4eedec2eb2d74f4613b18a1e410c8b8e6fcb7adf";
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
