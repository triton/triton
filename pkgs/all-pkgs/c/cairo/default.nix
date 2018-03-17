{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, lib

#, cogl
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
  name = "cairo-1.15.10";

  src = fetchurl {
    urls = [
      "https://cairographics.org/releases/${name}.tar.xz"
      "https://cairographics.org/snapshots/${name}.tar.xz"
    ];
    multihash = "QmUQwof2ut5B3fGCEqxGMwJffwTCc4QWX8NVW9GNV5NAqX";
    hashOutput = false;
    sha256 = "62ca226134cf2f1fd114bea06f8b374eb37f35d8e22487eaa54d5e9428958392";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    #cogl
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
    '' + optionalString (!opengl-dummy.glx) /* tests and perf tools require Xorg */ ''
      sed -i Makefile.am \
        -e '/^SUBDIRS/ s#boilerplate test perf# #'
    '';

  configureFlags = [
    "--disable-valgrind"
    "--${boolEn opengl-dummy.glx}-xlib"
    "--${boolEn opengl-dummy.glx}-xlib-xrender"
    "--${boolEn opengl-dummy.glx}-xcb"
    "--${boolEn opengl-dummy.glx}-xlib-xcb"
    "--${boolEn opengl-dummy.glx}-xcb-shm"
    "--disable-qt"
    "--disable-quartz"
    "--disable-quartz-font"  # macOS
    "--disable-quartz-image"  # macOS
    "--disable-win32"  # Windows
    "--disable-win32-font"  # Windows
    # TODO: package skia
    "--disable-skia"
    "--disable-os2"
    "--disable-beos"
    "--disable-drm"
    "--disable-gallium"
    # Only one OpenGL backend may be selected at compile time
    # OpenGL X (gl), or OpenGL ES 2.0 (glesv2)
    "--${boolEn opengl-dummy.glx}-gl"
    "--${boolEn (opengl-dummy.glesv2 && !opengl-dummy.glx)}-glesv2"
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
    "--${boolEn opengl-dummy.glx}-tee"
    "--enable-xml"
    "--enable-pthread"
    "--enable-gobject"
    "--disable-full-testing"
    "--disable-trace"
    "--enable-interpreter"
    "--disable-symbol-lookup"
    "--${boolWt opengl-dummy.glx}-x"
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
