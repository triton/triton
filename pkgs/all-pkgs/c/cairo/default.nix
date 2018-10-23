{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, fontconfig
, freetype
, glib
, libpng
, libspectre
, libx11
, libxcb
, libxext
, libxrender
, lzo
, opengl-dummy
, xorg
, xorgproto
, zlib
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "cairo-1.16.0";

  src = fetchurl {
    urls = [
      "https://cairographics.org/releases/${name}.tar.xz"
      "https://cairographics.org/snapshots/${name}.tar.xz"
    ];
    multihash = "QmShc68SuMhes22Uqts2BSXB2HKnPFFgguvztG3YmMdVxk";
    hashOutput = false;
    sha256 = "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331";
  };

  buildInputs = [
    fontconfig
    freetype
    glib
    libpng
    libspectre
    lzo
    opengl-dummy
    xorg.pixman
    zlib
  ] ++ optionals opengl-dummy.glx [
    libx11
    libxcb
    libxext
    libxrender
    xorgproto
  ];

  patches = [
    (fetchTritonPatch {
      rev = "082637366675031d5c64f34f3ff866cc965f7c9f";
      file = "cairo/cairo-respect-fontconfig.patch";
      sha256 = "1732f21adfe5ab291d987b7537b13470266253f599901a4707d27fd2b3d66734";
    })
  ];

  postPatch =
    /* Work around broken pkg-config `Requires.private' that prevents
       Freetype `-I' cflags from being propagated. */ ''
      sed -i src/cairo.pc.in \
        -e 's|^Cflags:\(.*\)$|Cflags: \1 -I${freetype}/include/freetype2 -I${freetype}/include|g'
    '' + /* Don't build tests */ ''
      grep -q 'am__append_1 = .*test' Makefile.in
      sed -i Makefile.in \
        -e '/am__append_1 =/ s# test##'
    '' + optionalString (!opengl-dummy.glx) /* tests and perf tools require Xorg */ ''
      sed -i Makefile.in \
        -e '/am__append_1 =/ s# \(boilerplate\|perf\)##'
    '';

  configureFlags = [
    "--disable-valgrind"
    "--${boolEn opengl-dummy.glx}-xlib"
    "--${boolEn opengl-dummy.glx}-xlib-xrender"
    "--${boolEn opengl-dummy.glx}-xcb"
    "--${boolEn opengl-dummy.glx}-xlib-xcb"
    "--${boolEn opengl-dummy.glx}-xcb-shm"
    "--disable-quartz"
    "--disable-quartz-font"  # macOS
    "--disable-quartz-image"  # macOS
    "--disable-win32"  # Windows
    "--disable-win32-font"  # Windows
    # Only one OpenGL backend may be selected at compile time
    # OpenGL X (gl), or OpenGL ES 2.0 (glesv2)
    "--${boolEn opengl-dummy.glx}-gl"
    "--${boolEn (opengl-dummy.glesv2 && !opengl-dummy.glx)}-glesv2"
    "--${boolEn (opengl-dummy.glesv3 && !opengl-dummy.glx)}-glesv3"
    "--${boolEn (opengl-dummy.egl)}-egl"
    "--${boolEn (opengl-dummy.glx)}-glx"
    "--disable-wgl"  # Windows
    "--enable-ft"
    "--enable-fc"
    "--${boolEn opengl-dummy.glx}-tee"
    "--enable-xml"
    "--enable-gobject"
    "--disable-full-testing"
    "--${boolWt opengl-dummy.glx}-x"
  ];

  postInstall = glib.flattenInclude;

  bindnow = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        sha1Urls = map (n: "${n}.sha1.asc") src.urls;
        pgpKeyFingerprint = "C722 3EBE 4EF6 6513 B892  5989 11A3 0156 E0E6 7611";
      };
    };
  };

  meta = with lib; {
    description = "A vector graphics library with cross-device output support";
    homepage = http://cairographics.org/;
    license = with licenses; [
      lgpl2Plus
      mpl10
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
