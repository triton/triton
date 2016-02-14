{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, libiconv

, cogl
, fontconfig
, freetype
, glib
, libpng
, libspectre
, lzo
, pixman
, mesa_noglu
, xorg
, zlib

, gles2 ? false
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString;
};

assert xorg != null ->
  xorg.libX11 != null
  && xorg.libxcb != null
  && xorg.libXext != null
  && xorg.libXrender != null;

stdenv.mkDerivation rec {
  name = "cairo-1.14.6";

  src = fetchurl {
    url = "http://cairographics.org/releases/${name}.tar.xz";
    sha256 = "0lmjlzmghmr27y615px9hkm552x7ap6pmq9mfbzr6smp8y2b6g31";
  };

  nativeBuildInputs = [
    autoreconfHook
  ] ++ optionals (!stdenv.cc.isGNU) [
    libiconv
  ];

  buildInputs = [
    fontconfig
    freetype
    glib
    libpng
    libspectre
    lzo
    mesa_noglu
    pixman
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXrender
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
    (enFlag "xlib" (xorg != null) null)
    (enFlag "xlib-xrender" (xorg != null) null)
    (enFlag "xcb" (xorg != null) null)
    (enFlag "xlib-xcb" (xorg != null) null)
    (enFlag "xcb-shm" (xorg != null) null)
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
    (enFlag "libpng" (libpng != null) null)
    # Only one OpenGL backend may be selected at compile time
    # OpenGL X (gl), or OpenGL ES 2.0 (glesv2)
    (enFlag "gl" (!gles2) null)
    (enFlag "glesv2" gles2 null)
    "--disable-cogl" # recursive dependency
    # FIXME: fix directfb mirroring
    "--disable-directfb"
    "--disable-vg"
    (enFlag "egl" (mesa_noglu != null) null)
    (enFlag "glx" (mesa_noglu != null) null)
    "--disable-wgl"
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
    "--with-x"
    #(wtFlag "skia" true "yes")
    #(wtFlag "skia-build-type" true "Release")
    "--without-gallium"
  ];

  postInstall = ''
    rm -rvf $out/share/gtk-doc
  '' + glib.flattenInclude;

  meta = with stdenv.lib; {
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
      i686-linux
      ++ x86_64-linux;
  };
}
