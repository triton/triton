{ stdenv
, cmake
, fetchFromGitHub

, openssl
}:

stdenv.mkDerivation {
  name = "civetweb-2016-04-20";

  src = fetchFromGitHub {
    version = 1;
    owner = "civetweb";
    repo = "civetweb";
    rev = "47e1dc92ac12e02eabb407418c13586243de90ef";
    sha256 = "ef8ab78403e65d814f7fccffe64a463bc880f13ebf3ed8e050dbd4fcbc7de442";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    openssl
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCIVETWEB_ALLOW_WARNINGS=ON"
    "-DCIVETWEB_ENABLE_CXX=ON"
    "-DCIVETWEB_ENABLE_IPV6=ON"
    "-DCIVETWEB_ENABLE_WEBSOCKETS=ON"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
