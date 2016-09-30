{ stdenv
, fetchurl

, libpng
, zlib
}:

let
  version = "1.8.7";
in
stdenv.mkDerivation rec {
  name = "pngcrush-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/pmt/pngcrush/${version}/${name}-nolib.tar.xz";
    hashOutput = false;
    sha256 = "f0cfc0d6f4df67106a184600f891b164875b6be7173111c87bec48a509fac60b";
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
      insecureProtocolDowngrade = true;
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
