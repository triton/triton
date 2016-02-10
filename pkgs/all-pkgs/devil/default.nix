{ stdenv
, fetchTritonPatch
, fetchurl

, libjpeg
, libpng
, libmng
, lcms1
, libtiff
, openexr
, mesa
, xorg
}:

stdenv.mkDerivation rec {

  name ="devil-${version}";
  version = "1.7.8";

  src = fetchurl {
    url = "mirror://sourceforge/openil/DevIL-${version}.tar.gz";
    sha256 = "1zd850nn7nvkkhasrv7kn17kzgslr5ry933v6db62s4lr0zzlbv8";
  };

  buildInputs = [
    libjpeg
    libpng
    libmng
    lcms1
    libtiff
    openexr
    mesa
    xorg.libX11
  ];

  patches = [
    (fetchTritonPatch {
      rev = "cf9180e71e03a959247600c2f95bcd83eae0cf33";
      file = "devil/devil-1.7.8-CVE-2009-3994.patch";
      sha256 = "c1e7ec4b04d28feaf5849ac8a3532291c0e17bde5aa80e71a77fbfe12cdf4c0b";
    })
    (fetchTritonPatch {
      rev = "cf9180e71e03a959247600c2f95bcd83eae0cf33";
      file = "devil/devil-1.7.8-libpng14.patch";
      sha256 = "bd1da681157678fcffcaba5ec2f7f2d33ad9971816ea33dedcf2721ad0ab4536";
    })
    (fetchTritonPatch {
      rev = "cf9180e71e03a959247600c2f95bcd83eae0cf33";
      file = "devil/devil-1.7.8-nvtt-glut.patch";
      sha256 = "ca71052737a94cb76edc47f7fe143d871cfdb397cc5039fd3703ee6d34e73cc1";
    })
    (fetchTritonPatch {
      rev = "cf9180e71e03a959247600c2f95bcd83eae0cf33";
      file = "devil/devil-1.7.8-ILUT.patch";
      sha256 = "869678fd287d058581d2667dbfde9718eff9bafdc6e76d629ab549a10ac8312c";
    })
    (fetchTritonPatch {
      rev = "cf9180e71e03a959247600c2f95bcd83eae0cf33";
      file = "devil/devil-1.7.8-restrict.patch";
      sha256 = "f30f4f95a208963af7fcf5de68c2a94db55911b34b9feef2c4324673388784c3";
    })
    (fetchTritonPatch {
      rev = "d9c8086c01e7808d3a61313eb3ffa296973d75f9";
      file = "devil/devil-1.7.8-fix-test.patch";
      sha256 = "cc453fc208f5f234083a9d34a2e9a109092b22deddd56afd1466b8e84640adfc";
    })
  ];

  preConfigure = ''
    sed -i configure \
      -e 's, -std=gnu99,,g'
    sed -i src-ILU/ilur/ilur.c \
      -e 's,malloc.h,stdlib.h,g'
  '' + stdenv.lib.optionalString stdenv.cc.isClang ''
    sed -i lib/Makefile.in \
      -e 's/libIL_la_CXXFLAGS = $(AM_CFLAGS)/libIL_la_CXXFLAGS =/g'
  '';

  configureFlags = [
    "--enable-ILU"
    "--enable-ILUT"
  ];

  postConfigure = ''
    sed -i include/IL/config.h \
      -e '/RESTRICT_KEYWORD/d'
  '';

  meta = with stdenv.lib; {
    description = "DevIL image library";
    homepage = http://openil.sourceforge.net/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
