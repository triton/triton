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
    version = 1;
    owner = "google";
    repo = "snappy";
    rev = version;
    sha256 = "df0ed01b58334a43a0f81b49bf8c3b51c5845385e1d081c7b65c01dac2b3ccd2";
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
