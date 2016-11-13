{ stdenv
, bison
, cmake
, fetchTritonPatch
, fetchurl
, gettext
, gperf
, perl
, python
, ruby

, at-spi2-core
, atk
, cairo
, enchant
, fontconfig
, freetype
, gdk-pixbuf
, geoclue
, glib
, gobject-introspection
, gnutls
, gst-plugins-base
, gstreamer
, gtk3
, harfbuzz
, icu
, libjpeg
, libnotify
, libpng
, libsecret
, libsoup
, libwebp
, libxml2
, libxslt
, mesa_noglu
, pango
, sqlite
, wayland
, xorg
, zlib

# gtkunixprint
# gudev
# openwebrtc
# libseccomp
# libhyphen
}:

with {
  inherit (stdenv.lib)
    boolOn
    optionals;
};

assert xorg != null ->
  xorg.libX11 != null;

stdenv.mkDerivation rec {
  name = "webkitgtk-2.14.2";

  src = fetchurl rec {
    url = "https://webkitgtk.org/releases/${name}.tar.xz";
    hashOutput = false;
    sha256 = "2edbcbd5105046aea55af9671c4de8deedb5b0e3567c618034d440a760675556";
  };

  nativeBuildInputs = [
    bison
    cmake
    gettext
    gperf
    perl
    python
    ruby
  ];

  buildInputs = [
    at-spi2-core
    atk
    cairo
    enchant
    fontconfig
    freetype
    gdk-pixbuf
    geoclue
    glib
    gobject-introspection
    gnutls
    gst-plugins-base
    gstreamer
    gtk3
    harfbuzz
    icu
    libjpeg
    libnotify
    libpng
    libsecret
    libsoup
    libwebp
    libxml2
    libxslt
    mesa_noglu
    pango
    sqlite
    wayland
  ] ++ optionals (xorg != null) [
    xorg.libX11
    xorg.libXau
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "7a86b94c61553bfa090488c0b73c477bdc062b7c";
      file = "webkitgtk/webkit-gtk-2.10.x-finding-harfbuzz-icu.patch";
      sha256 = "8eb3f4844b06c3c060233396045248a883177e9a09c491ddfaf9897d8e8ca2c4";
    })
  ];

  postPatch = ''
    patchShebangs ./Tools
  '';

  cmakeFlags = [
    "-DPORT=GTK"
    "-DENABLE_PLUGIN_PROCESS_GTK2=OFF"

    "-DENABLE_WEBKIT=OFF"
    "-DENABLE_WEBKIT2=ON"
    "-DENABLE_TOOLS=ON"
    # Shared library causes linker failures
    "-DSHARED_CORE=OFF"
    "-DENABLE_API_TESTS=OFF"

    "-DENABLE_GRAPHICS_CONTEXT_3D=ON"
    "-DENABLE_GTKDOC=OFF"
    "-DENABLE_INTROSPECTION=${boolOn (gobject-introspection != null)}"
    "-DUSE_REDIRECTED_XCOMPOSITE_WINDOW=ON"

    "-DENABLE_DEVELOPER_MODE=OFF"

    # Optional libraries
    "-DENABLE_CREDENTIAL_STORAGE=${boolOn (libsecret != null)}"
    "-DENABLE_JIT=ON"
    "-DENABLE_FTL_JIT=OFF" # llvm
    # TODO: add gudev support
    "-DENABLE_GAMEPAD_DEPRECATED=OFF"
    "-DENABLE_GEOLOCATION=${boolOn (geoclue != null)}"
    # TODO: add openwebrtc support
    "-DENABLE_MEDIA_STREAM=OFF"
    "-DENABLE_OPENGL=${boolOn (mesa_noglu != null)}"
    "-DENABLE_GLES2=${boolOn (mesa_noglu != null)}"
    "-DENABLE_PLUGIN_PROCESS_GTK2=OFF"
    "-DENABLE_SECCOMP_FILTERS=OFF"
    "-DENABLE_SPELLCHECK=${boolOn (enchant != null)}"
    "-DENABLE_SUBTLE_CRYPTO=${boolOn (gnutls != null)}"
    "-DENABLE_VIDEO=${boolOn (gstreamer != null && gst-plugins-base != null)}"
    "-DENABLE_WEB_AUDIO=${boolOn (gstreamer != null && gst-plugins-base != null)}"
    # TODO: add gstreamer mpeg-ts support
    "-DUSE_GSTREAMER_MPEGTS=OFF"
    # TODO: add gstreamer GL support
    "-DUSE_GSTREAMER_GL=OFF"
    "-DENABLE_X11_TARGET=${boolOn (xorg != null)}"
    # TODO: add wayland support (linker errors)
    "-DENABLE_WAYLAND_TARGET=${boolOn (wayland != null)}"
    "-DUSE_LIBNOTIFY=${boolOn (libnotify != null)}"
    # TODO: add libhyphen support
    "-DUSE_LIBHYPHEN=OFF"
  ];

  # WebKit2 missing include path for gst-plugins-base.
  # https://bugs.webkit.org/show_bug.cgi?id=148894
  NIX_CFLAGS_COMPILE = [
    "-I${gst-plugins-base}/include/gstreamer-1.0"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha1Url = map (n: "${n}.sha1") src.urls;
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Web content rendering engine, GTK+ port";
    homepage = "http://webkitgtk.org/";
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
