{ stdenv
, fetchurl

, boost
, expat
, zlib
}:

stdenv.mkDerivation rec {
  name = "exempi-2.4.3";

  src = fetchurl {
    url = "https://libopenraw.freedesktop.org/download/${name}.tar.bz2";
    multihash = "QmfTEwqMU4JD53xJLXBXTLAfBJSndbb3PgpWWAQpbiVJ4Q";
    hashOutput = false;
    sha256 = "bfd1d8ebffe07918a5bfc7a5130ff82486d35575827cae8d131b9fa1c0c29c6e";
  };

  buildInputs = [
    boost
    expat
    zlib
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      # Hubert Figuiere
      pgpKeyFingerprint = "6C44 DB3E 0BF3 EAF5 B433  239A 5FEE 05E6 A56E 15A3";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Implementation of XMP";
    homepage = http://libopenraw.freedesktop.org/wiki/Exempi/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
