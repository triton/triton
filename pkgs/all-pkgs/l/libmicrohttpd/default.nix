{ stdenv
, fetchurl

, gnutls
, libgcrypt
}:

stdenv.mkDerivation rec {
  name = "libmicrohttpd-0.9.59";

  src = fetchurl {
    url = "mirror://gnu/libmicrohttpd/${name}.tar.gz";
    hashOutput = false;
    sha256 = "9b9ccd7d0b11b0e179f1f58dc2caa3e0c62c8609e1e1dc7dcaadf941b67d923c";
  };

  buildInputs = [
    gnutls
    libgcrypt
  ];

  configureFlags = [
    "--disable-examples"
    "--disable-curl"  # Testcases
    "--enable-https"
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
