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
  version = "2.1.3";
in
stdenv.mkDerivation rec {
  name = "qca-${version}";
  
  src = fetchurl {
    url = "mirror://kde/stable/qca/${version}/src/${name}.tar.xz";
    sha256 = "003fd86a32421057a03b18a8168db52e2940978f9db5ebbb6a08882f8ab1e353";
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
