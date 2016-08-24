{ stdenv
, fetchurl

, libpng
, zlib
}:

stdenv.mkDerivation rec {
  name = "pngcrush-1.8.5";

  src = fetchurl {
    url = "mirror://sourceforge/pmt/${name}-nolib.tar.xz";
    multihash = "QmbFB4XbmSyLSm6qYDtTrUo7DkR3u7iiNYsJqbiKswbqhr";
    allowHashOutput = false;
    sha256 = "1f843d836de8ef90b99b0a9e3e37f4ff4776278b5605293d5644b6efd537d934";
  };

  buildInputs = [
    libpng
    zlib
  ];

  postPatch = /* Fix hardcoded install prefix */ ''
    sed -i Makefile \
      -e "s,/usr,$out,"
  '';

  makeFlags = [
    "PNGINC=${libpng}/include"
    "PNGLIB=${libpng}/lib"
    "ZINC=${zlib}/include"
    "ZLIB=${zlib}/lib"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "8048 643B A2C8 40F4 F92A  195F F549 84BF A16C 640F";
    };
  };

  meta = with stdenv.lib; {
    description = "Portable Network Graphics (PNG) optimizing utility";
    homepage = http://pmt.sourceforge.net/pngcrush;
    license = licenses.free; # pngcrush license
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
