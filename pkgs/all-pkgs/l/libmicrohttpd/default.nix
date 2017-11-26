{ stdenv
, fetchurl

, gnutls
, libgcrypt
, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libmicrohttpd-0.9.56";

  src = fetchurl {
    url = "mirror://gnu/libmicrohttpd/${name}.tar.gz";
    hashOutput = false;
    sha256 = "2c23b938114b1fa14cf47d1b4cdb0f4c5d86b7905c4f3a40684bdea129640789";
  };

  buildInputs = [
    gnutls
    libgcrypt
    openssl
    zlib
  ];

  configureFlags = [
    "--with-threads=posix"
    "--enable-doc"
    "--disable-examples"
    "--enable-poll=auto"
    "--enable-epoll=auto"
    "--enable-socketpair"
    "--disable-curl"
    "--enable-spdy"
    "--enable-messages"
    "--enable-postprocessor"
    "--with-gnutls"
    "--enable-https"
    "--enable-bauth"
    "--enable-dauth"
    "--disable-coverage"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        "D842 3BCB 326C 7907 0339  29C7 939E 6BE1 E29F C3CC"
        # Evgeny Grin (Karlson2k)
        "289F E99E 138C F6D4 73A3  F0CF BF7A C4A5 EAC2 BAF4"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Embeddable HTTP server library";
    homepage = http://www.gnu.org/software/libmicrohttpd/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
