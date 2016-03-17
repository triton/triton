{ stdenv
, fetchurl

, c-ares
, libssh2
, libxml2
, openssl
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  name = "aria2-${version}";
  version = "1.21.0";

  src = fetchurl {
    url = "https://github.com/tatsuhiro-t/aria2/releases/download/release-${version}/${name}.tar.xz";
    sha256 = "225c5f2c8acc899e0a802cdf198f82bd0d3282218e80cdce251b1f9ffacf6580";
  };

  buildInputs = [
    openssl
    c-ares
    libxml2
    sqlite
    zlib
    libssh2
  ];

  configureFlags = [
    "--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
  ];

  meta = with stdenv.lib; {
    homepage = https://github.com/tatsuhiro-t/aria2;
    description = "A lightweight, multi-protocol, multi-source, command-line download utility";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
