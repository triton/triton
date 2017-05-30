{ stdenv
, fetchurl

, gnutls
, libgcrypt
, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libmicrohttpd-0.9.55";

  src = fetchurl {
    url = "mirror://gnu/libmicrohttpd/${name}.tar.gz";
    hashOutput = false;
    sha256 = "0c1cab8dc9f2588bd3076a28f77a7f8de9560cbf2d80e53f9a8696ada80ed0f8";
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
