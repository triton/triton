{ stdenv
, fetchurl

, zlib
}:

let
  version = "1.6.35";
in
stdenv.mkDerivation rec {
  name = "libpng-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng16/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "23912ec8c9584917ed9b09c5023465d71709dce089be503c7867fec68a93bcd7";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng16/${version}/${name}-apng.patch.gz";
      sha256 = "18ceb239857bbd32ca706cdad29f1a5dcfb87a5c54258db3bb077cff78c12e04";
    })
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "8048 643B A2C8 40F4 F92A  195F F549 84BF A16C 640F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "The official reference implementation for the PNG file format with animation patch";
    homepage = http://www.libpng.org/pub/png/libpng.html;
    license = licenses.libpng;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
