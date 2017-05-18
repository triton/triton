{ stdenv
, fetchurl

, c-ares
, libssh2
, libxml2
, openssl
, sqlite
, zlib
}:

let
  version = "1.32.0";
in
stdenv.mkDerivation rec {
  name = "aria2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "546e9194a9135d665fce572cb93c88f30fb5601d113bfa19951107ced682dc50";
  };

  buildInputs = [
    c-ares
    libssh2
    libxml2
    openssl
    sqlite
    zlib
  ];

  configureFlags = [
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
  ];

  meta = with stdenv.lib; {
    description = "A multi-protocol/source, command-line download utility";
    homepage = https://github.com/tatsuhiro-t/aria2;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
