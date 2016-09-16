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
  version = "1.27.0";
in
stdenv.mkDerivation rec {
  name = "aria2-${version}";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/"
      + "release-${version}/${name}.tar.xz";
    sha256 = "166538f3460e405e9812981a4748799fb191ab0bd68e9b38a8e6be0553f9248c";
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
