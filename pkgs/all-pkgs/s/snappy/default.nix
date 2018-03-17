{ stdenv
, autoreconfHook
, cmake
, fetchFromGitHub
, ninja

, lzo
, zlib
}:

let
  version = "1.1.7";
in
stdenv.mkDerivation rec {
  name = "snappy-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "google";
    repo = "snappy";
    rev = version;
    sha256 = "5dba0e94670b7f5190d448150228030fe0458805959ca389ca3818beded96293";
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
