{ stdenv
, fetchurl

, gnutls
, libgcrypt
, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libmicrohttpd-0.9.50";

  src = fetchurl {
    url = "mirror://gnu/libmicrohttpd/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "d1b6385068abded29b6470e383287aa7705de05ae3c08ad0bf5747ac4dc6ebd7";
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
      pgpKeyFingerprint = "D842 3BCB 326C 7907 0339  29C7 939E 6BE1 E29F C3CC";
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
