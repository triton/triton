{ stdenv
, cmake
, fetchFromGitHub
, ninja

, zlib
}:

let
  date = "2017-04-30";
  rev = "0400fb5e9cf8fd84f7ad5f59822fa2c9d48e1267";
in
stdenv.mkDerivation rec {
  name = "chck-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "Cloudef";
    repo = "chck";
    inherit rev;
    sha256 = "57f5dfc92251067865c9b42cb0098c647e2a7970b9707bd7603731dcee99cc5e";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    zlib
  ];

  cmakeFlags = [
    "-DCHCK_BUILD_TESTS=OFF"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
