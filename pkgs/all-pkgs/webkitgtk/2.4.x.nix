{ stdenv
, autoreconfHook
, bison
, fetchTritonPatch
, fetchurl
, flex
, gettext
, gperf
, perl
, python
, ruby
, which

, atk
, cairo
, enchant
, fontconfig
, freetype
, gdk-pixbuf
, geoclue2
, glib
, gobject-introspection
, gtk2
, gtk3
, gst-plugins-base
, gstreamer
, harfbuzz
, icu
, libjpeg
, libpng
, libsecret
, libsoup
, libwebp
, libxml2
, libxslt
, pango
, mesa_noglu
, sqlite
, upower
, wayland
, xorg
, zlib

, gtkVer ? "3"
}:

# TODO: When adding doc support, re-add autoreconf for gtk-docsize patch
#       and update webcore-svg-libxml-cflags.patch to patch *.am.

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

assert (gtkVer == "2" || gtkVer == "3");

stdenv.mkDerivation rec {
  name = "webkitgtk-2.4.9";

  src = fetchurl {
    url = "http://webkitgtk.org/releases/${name}.tar.xz";
    sha256 = "0r651ar3p0f8zwl7764kyimxk5hy88cwy116pv8cl5l8hbkjkpxg";
  };

  nativeBuildInputs = [
    bison
    flex
    gettext
    gperf
    perl
    python
    ruby
    which
  ];

  buildInputs = [
    atk
    cairo
    enchant
    fontconfig
    freetype
    gdk-pixbuf
    geoclue2
    glib
    gobject-introspection
    gtk2
    gtk3
    gst-plugins-base
    gstreamer
    harfbuzz
    icu
    libjpeg
    libpng
    libsecret
    libsoup
    libwebp
    libxml2
    libxslt
    pango
    mesa_noglu
    sqlite
    upower
    wayland
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXrender
    xorg.libXt
    zlib
  ];

  CC = "cc";

  patches = [
    # https://bugs.webkit.org/show_bug.cgi?id=113397
    (fetchTritonPatch {
      rev = "6abc19d8cdde923ac47c84223bfa7c784b9b5b94";
      file = "webkitgtk/webkit-gtk-1.11.90-gtk-docize-fix.patch";
      sha256 = "1e70b12e8b90a35229f53c74e68d150555c8290e656fa1763fb2b9c1af352884";
    })
    # Fix build with recent libjpeg
    # https://bugs.webkit.org/show_bug.cgi?id=122412
    (fetchTritonPatch {
      rev = "6cc6ef88e3830b254059e869fe8e97153794c836";
      file = "webkitgtk/webkit-gtk-2.4.9-jpeg-9a.patch";
      sha256 = "b442a8021ec5bfc751708fe6409baff6ae8576d7fb49da95245b6ba2c1557536";
    })
    # Fix building with --disable-webgl
    # https://bugs.webkit.org/show_bug.cgi?id=131267
    (fetchTritonPatch {
      rev = "b03892aa1ca4dcc06e7c56bbecff3b65a778472c";
      file = "webkitgtk/webkit-gtk-2.4.7-disable-webgl.patch";
      sha256 = "6fb78d5f94806ddb976ceb076e623a2fd67e80111d624a2b3c01fde2fbbcd64e";
    })
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "webkitgtk/webkit-gtk-2.4.9-webcore-svg-libxml-cflags.patch";
      sha256 = "4d1938540903afa8ecc2ad84cb680687bc7ab724d15df953d8fe390e3914134a";
    })
  ];

  postPatch = ''
    patchShebangs ./Tools/gtk
  '';

  configureFlags = [
    "--enable-largefile"
    "--enable-webkit1"
    "--disable-webkit2"
    "--disable-debug"
    "--disable-developer-mode"
    "--enable-optimizations"
    "--enable-x11-target"
    "--disable-wayland-target"
    "--disable-win32-target"
    "--disable-quartz-target"
    "--disable-directfb-target"
    (enFlag "spellcheck" (enchant != null) null)
    (enFlag "credential-storage" (libsecret != null) null)
    "--enable-glx"
    "--enable-egl"
    "--disable-gles2"
    "--disable-gamepad"
    "--enable-video"
    "--enable-geolocation"
    "--enable-svg"
    "--enable-svg-fonts"
    (enFlag "web-audio" (
      gstreamer != null
      && gst-plugins-base != null) null)
    "--disable-battery-status"
    "--disable-coverage"
    "--enable-fast-malloc"
    "--disable-debug-symbols"
    "--enable-webgl"
    "--enable-accelerated-compositing"
    "--enable-jit"
    "--disable-ftl-jit" # llvm
    "--disable-opcode-stats"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-glibtest"
    "--enable-schemas-compile"
    "--disable-maintainer-mode"
    "--with-gtk=${gtkVer}.0"
  ];

  dontAddDisableDepTrack = true;

  meta = with stdenv.lib; {
    description = "Web content rendering engine, GTK+ port";
    homepage = "http://webkitgtk.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
