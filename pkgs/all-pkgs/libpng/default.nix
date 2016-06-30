{ stdenv
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "libpng-${version}";
  version = "1.6.23";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${version}.tar.xz";
    allowHashOutput = false;
    multihash = "QmaFjRdSBz8wbYfHyPeL3uisFXPT9jEgyvmoed5wEjj9aj";
    sha256 = "6d921e7bdaec56e9f6594463ec1fe1981c3cd2d5fc925d3781e219b5349262f1";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng-${version}-apng.patch.gz";
      sha256 = "08906e0639a953f6be2d47857661cbdf04dcab93d3bf9f8cb0f7675567b07ad3";
    })
  ];

  passthru = {
    srcVerified = fetchurl {
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
