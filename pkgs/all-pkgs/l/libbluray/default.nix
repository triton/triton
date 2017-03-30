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

  version  = "1.0.0";
in
stdenv.mkDerivation rec {
  name = "libbluray-${version}";

  src = fetchurl {
    url = "mirror://videolan/libbluray/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f7e3add335c7bbef45824fcd2249a9bf293868598c13f8479352c44ec95374cc";
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

  postPatch = ''
    # Fix search path for BDJ jarfile
    # See triton-patches "libbluray/BDJ-JARFILE-path.patch"
    sed -i configure.ac \
      -e "/\[JDK_HOME\], \[\"\$JDK_HOME\"\]/a CPPFLAGS=\"''${CPPFLAGS} -DJARDIR='\\\\\"\\\$(datadir)/java\\\\\"'\""
    sed -i src/libbluray/bdj/bdj.c \
      -e 's|/usr/share/java/" BDJ_JARFILE|JARDIR "/" BDJ_JARFILE|'
  '';

  configureFlags = [
    "--disable-werror"
    "--enable-extra-warnings"
    "--enable-optimizations"
    "--disable-examples"
    "--${boolEn (jdk != null)}-bdjava"
    "--enable-udf"
    /**/"--disable-bdjava-jar"  # FIXME: Fix BDJ search path
    #"--${boolEn (jdk != null)}-bdjava-jar"
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
    "--with-bdj-type=j2se"  # j2me
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

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha512Urls = map (n: "${n}.sha512") src.urls;
      failEarly = true;
    };
  };

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
