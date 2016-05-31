{ stdenv
, fetchurl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libpng-${version}";
  version = "1.6.22";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${version}.tar.xz";
    allowHashOutput = false;
    multihash = "QmU3V85XU2KWpwXQzwSUbekrcgvXJFsKHttBQwwrrpAcaX";
    sha256 = "6b5a6ad5c5801ec4d24aacc87a0ed7b666cd586478174f69368a1d7747715226";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng-${version}-apng.patch.gz";
      sha256 = "8fdcd293873ae88364e7d58b6e4bfc49ff1d8ac6663abc207992dd2b27e16e8b";
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
