{ stdenv
, autoreconfHook
, fetchFromGitHub

, lzo
, zlib
}:

stdenv.mkDerivation rec {
  name = "snappy-${version}";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "google";
    repo = "snappy";
    rev = version;
    sha256 = "d7c1e3e88d3d470046f35a73658e63c25345fd9894735efb535cc8a5324a5c78";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    lzo
    zlib
  ];

  # -DNDEBUG for speed
  configureFlags = [
    "CXXFLAGS=-DNDEBUG"
    "--enable-shared"
    "--enable-static"
  ];

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    homepage = http://code.google.com/p/snappy/;
    license = licenses.bsd3;
    description = "Compression/decompression library for very high speeds";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
