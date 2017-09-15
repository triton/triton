{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, lib

, cogl
, fontconfig
, freetype
, glib
, libpng
, libspectre
, libx11
, libxcb
, lzo
, opengl-dummy
, xorg
, zlib

, gles2 ? false
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionalString;
in
stdenv.mkDerivation rec {
  name = "cairo-1.14.10";

  src = fetchurl {
    url = "https://cairographics.org/releases/${name}.tar.xz";
    multihash = "QmceAfwie7MyRPHeezGiTA7aUtMVrMKdT6v7YVq8yPavj7";
    hashOutput = false;
    sha256 = "7e87878658f2c9951a14fc64114d4958c0e65ac47530b8ac3078b2ce41b66a09";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    fontconfig
    freetype
    glib
    libpng
    libspectre
    libx11
    libxcb
    lzo
    opengl-dummy
    xorg.libXext
    xorg.libXrender
    xorg.pixman
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "082637366675031d5c64f34f3ff866cc965f7c9f";
      file = "cairo/cairo-respect-fontconfig.patch";
      sha256 = "1732f21adfe5ab291d987b7537b13470266253f599901a4707d27fd2b3d66734";
    })
    (fetchTritonPatch {
      rev = "082637366675031d5c64f34f3ff866cc965f7c9f";
      file = "cairo/cairo-1.12.18-disable-test-suite.patch";
      sha256 = "3ec119ac2380f8565cebbcea4f745e89eeb78686e76e6b15345a76f05812c254";
    })
  ];

  postPatch =
    /* Work around broken pkg-config `Requires.private' that prevents
       Freetype `-I' cflags from being propagated. */ ''
      sed -i src/cairo.pc.in \
        -e 's|^Cflags:\(.*\)$|Cflags: \1 -I${freetype}/include/freetype2 -I${freetype}/include|g'
    '' + optionalString (xorg == null)
    /* tests and perf tools require Xorg */ ''
      sed -i Makefile.am \
        -e '/^SUBDIRS/ s#boilerplate test perf# #'
    '';

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-largefile"
    #"--disable-atomic"
    "--disable-gcov"
    "--disable-valgrind"
    "--${boolEn (libx11 != null && xorg.libXext != null)}-xlib"
    "--${boolEn (libx11 != null && xorg.libXrender != null)}-xlib-xrender"
    "--${boolEn (libx11 != null && libxcb != null)}-xcb"
    "--${boolEn (libx11 != null && libxcb != null)}-xlib-xcb"
    "--${boolEn (libx11 != null && libxcb != null)}-xcb-shm"
    "--disable-qt"
    "--disable-quartz"
    "--disable-quartz-font"
    "--disable-quartz-image"
    "--disable-win32"
    "--disable-win32-font"
    # TODO: package skia
    "--disable-skia"
    "--disable-os2"
    "--disable-beos"
    "--disable-drm"
    "--disable-gallium"
    # Only one OpenGL backend may be selected at compile time
    # OpenGL X (gl), or OpenGL ES 2.0 (glesv2)
    "--${boolEn (!opengl-dummy.glexv2 && opengl-dummy.glx)}-gl"
    "--${boolEn opengl-dummy.glesv2}-glesv2"
    "--disable-cogl"  # recursive dependency
    # FIXME: fix directfb mirroring
    "--disable-directfb"
    "--disable-vg"
    "--${boolEn (opengl-dummy.egl)}-egl"
    "--${boolEn (opengl-dummy.glx)}-glx"
    "--disable-wgl"  # Windows
    "--enable-script"
    "--enable-ft"
    "--enable-fc"
    "--enable-ps"
    "--enable-pdf"
    "--enable-svg"
    "--disable-test-surfaces"
    "--enable-tee"
    "--enable-xml"
    "--enable-pthread"
    "--enable-gobject"
    "--disable-full-testing"
    "--disable-trace"
    "--enable-interpreter"
    "--disable-symbol-lookup"
    #"--enable-some-floating-point"
    "--${boolwt opengl-dummy.glx}-x"
    #(wtFlag "skia" true "yes")
    #(wtFlag "skia-build-type" true "Release")
    "--without-gallium"
  ];

  postInstall = ''
    rm -rvf $out/share/gtk-doc
  '' + glib.flattenInclude;

  bindnow = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      sha1Urls = map (n: "${n}.sha1.asc") src.urls;
      pgpKeyFingerprint = "C722 3EBE 4EF6 6513 B892  5989 11A3 0156 E0E6 7611";
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
