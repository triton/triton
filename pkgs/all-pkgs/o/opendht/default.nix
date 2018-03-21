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
  version = "1.6.1";
in
stdenv.mkDerivation rec {
  name = "opendht-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "savoirfairelinux";
    repo = "opendht";
    rev = version;
    sha256 = "d5da86c63fcafa83754a8a41bd95ee54a364eeb7a8e5397191c99702575140ee";
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
