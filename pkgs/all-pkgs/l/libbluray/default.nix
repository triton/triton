{ stdenv
, ant
, autoreconfHook
, fetchTritonPatch
, fetchurl
, lib

, fontconfig
, freetype
, jdk
, libaacs
, libbdplus
, libxml2
}:

let
  inherit (lib)
    boolEn
    boolWt;

  version  = "0.9.3";
in
stdenv.mkDerivation rec {
  name = "libbluray-${version}";

  src = fetchurl {
    url = "mirror://videolan/libbluray/${version}/${name}.tar.bz2";
    sha256 = "a6366614ec45484b51fe94fcd1975b3b8716f90f038a33b24d59978de3863ce0";
  };

  nativeBuildInputs = [
    ant
    autoreconfHook
  ];

  buildInputs = [
    fontconfig
    freetype
    jdk
    libaacs
    libxml2
  ];

  patches = [
    # Fix search path for BDJ jarfile
    (fetchTritonPatch {
      rev = "fea1481e3a5255acae6df3f2bcba5fdcc0b433a0";
      file = "libbluray/BDJ-JARFILE-path.patch";
      sha256 = "fc9ef430a85e61dc58932280da775d00c79a1487d55ee4c4955f7311170733a7";
    })
  ];

  configureFlags = [
    "--disable-werror"
    "--enable-optimizations"
    "--disable-examples"
    "--${boolEn (jdk != null)}-bdjava"
    "--disable-bdjava"
    "--enable-udf"
    "--disable-doxygen-doc"
    "--disable-doxygen-dot"
    "--disable-doxygen-man"
    "--disable-doxygen-rtf"
    "--disable-doxygen-xml"
    "--disable-doxygen-chm"
    "--disable-doxygen-chi"
    "--disable-doxygen-html"
    "--disable-doxygen-ps"
    "--disable-doxygen-pdf"
    "--${boolWt (libxml2 != null)}-libxml2"
    "--${boolWt (freetype != null)}-freetype"
    "--${boolWt (fontconfig != null)}-fontconfig"
    "--with-bdj-type=j2se"
    #"--with-bdj-bootclasspath="
  ];

  NIX_LDFLAGS = [
    "-L${libaacs}/lib"
    "-laacs"
    "-L${libbdplus}/lib"
    "-lbdplus"
  ];

  preConfigure = ''
    export JDK_HOME="${jdk.home}"
  '';

  meta = with lib; {
    description = "Library to access Blu-Ray disks for video playback";
    homepage = http://www.videolan.org/developers/libbluray.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
