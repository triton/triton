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
    version = 6;
    owner = "google";
    repo = "snappy";
    rev = version;
    sha256 = "9f2bca05556d72c4597ce4a1d6963676d11eb6ddb4606ea4ad6eed03899f3680";
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
