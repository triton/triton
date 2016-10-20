{ stdenv
, fetchurl

, zlib
}:

let
  libpng-apng = fetchurl {
    url = "mirror://sourceforge/libpng-apng/libpng16/1.6.26/libpng-1.6.26-apng.patch.gz";
    sha256 = "01dec904d91ee8c90a9a78f253d01d8fac0e37a3f4beacb60e136ea7c814d72c";
  };

  version = "1.6.26";
in
stdenv.mkDerivation rec {
  name = "libpng-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng16/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "266743a326986c3dbcee9d89b640595f6b16a293fd02b37d8c91348d317b73f9";
  };

  buildInputs = [
    zlib
  ];

  patchFlags = "-p0";

  /*patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng16/1.6.25/libpng-1.6.25-apng.patch.gz";
      sha256 = "e264d917d84872f01af3acf9666471a9bf64b75558b4b35236fef1e23c2a094f";
    })
  ];*/
  prePatch = ''
    echo "applying libpng-apng.patch"
    gzip -d < "${libpng-apng}" 2>&1 > libpng-apng.patch
    sed -i libpng-apng.patch \
      -e'/pngpriv.h/,/#define PNG_BGR/s|0x[0-9]*|&U|'
    patch ${patchFlags} libpng-apng.patch
  '';

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
