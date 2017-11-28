{ stdenv
, cmake
, fetchFromGitHub
, ninja

, openssl
}:

let
  version = "1.10";
in
stdenv.mkDerivation {
  name = "civetweb-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "civetweb";
    repo = "civetweb";
    rev = "v${version}";
    sha256 = "5fab1d15fd2f6c7433528e82243bd47e6d90a032e96da8524d499ec37a932fcf";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    openssl
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCIVETWEB_ENABLE_CXX=ON"
    "-DCIVETWEB_ENABLE_IPV6=ON"
    "-DCIVETWEB_ENABLE_WEBSOCKETS=ON"
    "-DCIVETWEB_ENABLE_SERVER_STATS=ON"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
