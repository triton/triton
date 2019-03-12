{ stdenv
, docbook-xsl
, fetchurl
, gengetopt
, lib

, bash-completion
, glib
, libxslt
, openpace
, openssl
, pcsc-lite_lib
, readline
, zlib
}:

let
  version = "0.19.0";
in
stdenv.mkDerivation rec {
  name = "opensc-${version}";

  src = fetchurl {
    url = "https://github.com/OpenSC/OpenSC/releases/download/${version}/${name}.tar.gz";
    sha256 = "2c5a0e4df9027635290b9c0f3addbbf0d651db5ddb0ab789cb0e978f02fd5826";
  };

  nativeBuildInputs = [
    gengetopt
    libxslt
  ];

  buildInputs = [
    bash-completion
    glib
    openpace
    openssl
    pcsc-lite_lib
    readline
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-xsl-stylesheetsdir=${docbook-xsl}/share/xml/docbook-xsl"
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "CVCDIR=$out/etc/eac/cvc"
    )
  '';

  preFixup = ''
    rm -r "$out"/lib/pkgconfig
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
