{ stdenv
, fetchurl
, gettext

, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, libdrm
, mesa_noglu
, pango
, wayland
, xorg

, channel ? "1.22"
}:

let
  inherit (stdenv.lib)
    boolEn
    optionalString;
in
stdenv.mkDerivation rec {
  name = "cogl-${channel}.2";

  src = fetchurl {
    url = "mirror://gnome/sources/cogl/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/cogl/${channel}/${name}.sha256sum";
    sha256 = "39a718cdb64ea45225a7e94f88dddec1869ab37a21b339ad058a9d898782c00d";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    gobject-introspection
    gst-plugins-base
    gstreamer
    libdrm
    mesa_noglu
    pango
    wayland
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
  ];

  postPatch =
    /* Don't build examples */ ''
      sed -i Makefile.{am,in} \
        -e "s/^\(SUBDIRS +=.*\)examples\(.*\)$/\1\2/"
    '' +
    /* Fix library name in pkg-config file */ ''
      sed -i cogl-pango/cogl-pango-2.0-experimental.pc.in \
        -e 's|-lcoglpango|-lcogl-pango|'
    '' + optionalString (!doCheck)
    /* The configure switch does not completely disable
       tests from being built */ ''
      sed -i Makefile.{am,in} \
        -e "s/^\(SUBDIRS =.*\)test-fixtures\(.*\)$/\1\2/" \
        -e "s/^\(SUBDIRS +=.*\)tests\(.*\)$/\1\2/" \
        -e "s/^\(.*am__append.* \)tests\(.*\)$/\1\2/"
    '';

  configureFlags = [
    "--disable-installed-tests"
    #"--enable-emscripten"
    "--disable-standalone"
    "--disable-debug"
    "--${boolEn doCheck}-unit-tests"
    "--${boolEn (cairo != null)}-cairo"
    "--disable-profile"
    "--disable-maintainer-flags"
    "--enable-deprecated"
    "--${boolEn (glib != null)}-glibtest"
    "--${boolEn (glib != null)}-glib"
    "--${boolEn (pango != null)}-cogl-pango"
    "--${boolEn (
      gstreamer != null
      && gst-plugins-base != null)}-cogl-gst"
    "--enable-cogl-path"
    "--${boolEn (gdk-pixbuf != null)}-gdk-pixbuf"
    "--disable-quartz-image"
    "--disable-examples-install"
    "--enable-gles1"
    "--enable-gles2"
    "--enable-gl"
    "--enable-cogl-gles2"
    "--enable-glx"
    "--disable-wgl"
    "--enable-null-egl-platform"
    "--disable-gdl-egl-platform"
    "--enable-wayland-egl-platform"
    "--enable-kms-egl-platform"
    "--enable-wayland-egl-server"
    "--disable-android-egl-platform"
    "--disable-mir-egl-platform"
    "--enable-xlib-egl-platform"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--enable-rpath"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--with-x"
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "2D graphics library with support for multiple output devices";
    homepage = http://cairographics.org/;
    license = with licenses; [
      mpl11
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
