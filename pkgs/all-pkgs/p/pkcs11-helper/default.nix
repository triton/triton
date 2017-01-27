{ stdenv
, fetchurl

, openssl
}:

let
  version = "1.21";
in
stdenv.mkDerivation rec {
  name = "pkcs11-helper-${version}";

  src = fetchurl {
    url = "https://github.com/OpenSC/pkcs11-helper/releases/download/${name}/${name}.tar.bz2";
    sha256 = "7bc455915590fec1a85593171f08a73ef343b1e7a73e60378d8744d54523e17c";
  };

  buildInputs = [
    openssl
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
