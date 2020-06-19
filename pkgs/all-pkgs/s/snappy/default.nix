{ stdenv
, autoreconfHook
, cmake
, fetchFromGitHub
, ninja

, lzo
, zlib
}:

let
  version = "1.1.8";
in
stdenv.mkDerivation rec {
  name = "snappy-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "google";
    repo = "snappy";
    rev = version;
    sha256 = "68065122872f48c29f98801ec7092345f94cbf6f18447e4dba9ceb6319c0c1db";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    lzo
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
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
