{ stdenv
, ant
, autoreconfHook
, fetchTritonPatch
, fetchurl

, fontconfig
, freetype
, jdk
, libaacs
, libbdplus
, libxml2
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "libbluray-${version}";
  version  = "0.9.2";

  src = fetchurl {
    url = "http://get.videolan.org/libbluray/${version}/${name}.tar.bz2";
    sha256 = "1sp71j4agcsg17g6b85cqz78pn5vknl5pl39rvr6mkib5ps99jgg";
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
    (enFlag "bdjava" (jdk != null) null)
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
    (wtFlag "libxml2" (libxml2 != null) null)
    (wtFlag "freetype" (freetype != null) null)
    (wtFlag "fontconfig" (fontconfig != null) null)
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

  meta = with stdenv.lib; {
    description = "Library to access Blu-Ray disks for video playback";
    homepage = http://www.videolan.org/developers/libbluray.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
