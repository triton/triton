{ stdenv
, cmake
, fetchurl
, ninja

, cyrus-sasl
, libgcrypt
, nss
, openssl
, pkcs11-helper
, qt5
}:

let
  version = "2.1.1";
in
stdenv.mkDerivation rec {
  name = "qca-${version}";
  
  src = fetchurl {
    url = "http://download.kde.org/stable/qca/${version}/src/${name}.tar.xz";
    sha256 = "10z9icq28fww4qbzwra8d9z55ywbv74qk68nhiqfrydm21wkxplm";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    cyrus-sasl
    libgcrypt
    nss
    openssl
    pkcs11-helper
    qt5
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
