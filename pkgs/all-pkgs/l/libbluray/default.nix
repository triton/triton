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

  version  = "1.1.1";
in
stdenv.mkDerivation rec {
  name = "libbluray-${version}";

  src = fetchurl {
    url = "mirror://videolan/libbluray/${version}/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "106478a17c8bcac8c7b4174e7432b2bad5a1e6dd2926c4224791fd4669472338";
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
    grep -q '[JDK_HOME],' configure.ac
    sed -i configure.ac \
      -e "/\[JDK_HOME\], \[\"\$JDK_HOME\"\]/a CPPFLAGS=\"''${CPPFLAGS} -DJARDIR='\\\\\"\\\$(datadir)/java\\\\\"'\""
    grep -q '"/usr/share/java/" BDJ_JARFILE' src/libbluray/bdj/bdj.c
    grep -q '"/usr/share/libbluray/lib/"' src/libbluray/bdj/bdj.c
    sed -i src/libbluray/bdj/bdj.c \
      -e 's|"/usr/share/java/" BDJ_JARFILE|JARDIR "/" BDJ_JARFILE|' \
      -e '/"\/usr\/share\/libbluray\/lib\/"/d'
    # Remove impure paths
    grep -q '/usr' src/libbluray/bdj/bdj.c
    sed -i src/libbluray/bdj/bdj.c \
      -e 's,/usr,/non-existent-path,' \
      -e 's,/etc,/non-existent-path,'
  '';

  configureFlags = [
    "--disable-werror"
    "--enable-extra-warnings"
    "--enable-optimizations"
    "--disable-examples"
    "--${boolEn (jdk != null)}-bdjava"
    "--enable-udf"
    "--${boolEn (jdk != null)}-bdjava-jar"
    "--with-libxml2"
    "--with-freetype"
    "--with-fontconfig"
    "--with-bdj-type=j2se"
    #"--with-bdj-bootclasspath="
  ];

  NIX_LDFLAGS = [
    "-L${libaacs}/lib" "-laacs"
    "-L${libbdplus}/lib" "-lbdplus"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha512Urls = map (n: "${n}.sha512") src.urls;
      };
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
