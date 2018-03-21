{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja

, boost
, gnutls
, jsoncpp
, libargon2
, msgpack-c
, ncurses
, nettle
, readline
, restbed
}:

let
  version = "1.6.0rc2";
in
stdenv.mkDerivation rec {
  name = "opendht-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "savoirfairelinux";
    repo = "opendht";
    rev = version;
    sha256 = "8786e3546db1902e1bb8c236e882a1a00a95fd07a88d6401a8ce630328a6248a";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    gnutls
    jsoncpp
    libargon2
    msgpack-c
    ncurses
    nettle
    readline
    restbed
  ];

  postPatch = ''
    sed -i "s,\''${systemdunitdir},$out/lib/systemd/system,g" tools/CMakeLists.txt
  '';

  cmakeFlags = [
    "-DOPENDHT_STATIC=OFF"
    "-DOPENDHT_SYSTEMD=ON"
    "-DOPENDHT_PROXY_SERVER=ON"
    "-DOPENDHT_PROXY_CLIENT=ON"
    "-DOPENDHT_PUSH_NOTIFICATIONS=ON"
  ];

  NIX_LDFLAGS = "-rpath ${boost.lib}/lib";

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
