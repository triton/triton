{ stdenv
, autoreconfHook
, fetchFromGitHub

, lzo
, zlib
}:

let
  version = "1.1.4";
in
stdenv.mkDerivation rec {
  name = "snappy-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "google";
    repo = "snappy";
    rev = version;
    sha256 = "ea51fc2c12aafbcd89bc65e859015fb7e63da0b95a952fbc52d0e624c301e484";
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

  disableStatic = false;

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
