{ stdenv
, fetchurl

, gnutls
, libgcrypt
}:

stdenv.mkDerivation rec {
  name = "libmicrohttpd-0.9.65";

  src = fetchurl {
    url = "mirror://gnu/libmicrohttpd/${name}.tar.gz";
    hashOutput = false;
    sha256 = "f2467959c5dd5f7fdf8da8d260286e7be914d18c99b898e22a70dafd2237b3c9";
  };

  buildInputs = [
    gnutls
    libgcrypt
  ];

  configureFlags = [
    "--disable-doc"
    "--disable-examples"
    "--disable-curl"  # Testcases
    "--enable-https"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          "D842 3BCB 326C 7907 0339  29C7 939E 6BE1 E29F C3CC"
          # Evgeny Grin (Karlson2k)
          "289F E99E 138C F6D4 73A3  F0CF BF7A C4A5 EAC2 BAF4"
        ];
      };
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
