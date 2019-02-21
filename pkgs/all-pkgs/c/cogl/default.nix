{ stdenv
, fetchurl
, gettext
, lib

, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gst-plugins-base
, gstreamer
, libdrm
, libx11
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxrandr
, opengl-dummy
, pango
, wayland

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals
    optionalString;

  sources = {
    "1.22" = {
      version = "1.22.2";
      sha256 = "39a718cdb64ea45225a7e94f88dddec1869ab37a21b339ad058a9d898782c00d";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "cogl-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/cogl/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    opengl-dummy
    pango
  ] ++ optionals opengl-dummy.egl [
    libdrm
    wayland
  ] ++ optionals (opengl-dummy.glx || opengl-dummy.egl) [
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
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
    "--enable-cairo"
    "--disable-profile"
    "--disable-maintainer-flags"
    "--enable-deprecated"
    "--enable-glibtest"
    "--enable-glib"
    "--enable-cogl-pango"
    "--enable-cogl-gst"
    "--enable-cogl-path"
    "--enable-gdk-pixbuf"
    "--disable-quartz-image"
    "--disable-examples-install"
    "--${boolEn opengl-dummy.glesv1}-gles1"
    "--${boolEn opengl-dummy.glesv2}-gles2"
    "--enable-gl"
    "--${boolEn opengl-dummy.glesv2}-cogl-gles2"
    "--${boolEn opengl-dummy.glx}-glx"
    "--disable-wgl"  # Windows
    "--${boolEn opengl-dummy.egl}-null-egl-platform"
    "--disable-gdl-egl-platform"  # Windows
    "--${boolEn (opengl-dummy.egl && opengl-dummy.gbm)}-wayland-egl-platform"
    "--${boolEn (opengl-dummy.egl && opengl-dummy.gbm)}-kms-egl-platform"
    "--${boolEn opengl-dummy.egl}-wayland-egl-server"
    "--disable-android-egl-platform"  # Android
    "--disable-mir-egl-platform"  # DEPRECATED
    "--${boolEn opengl-dummy.egl}-xlib-egl-platform"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-nls"
    "--enable-rpath"
    "--enable-introspection"
    "--${boolWt opengl-dummy.glx}-x"
  ];

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (n: (lib.replaceStrings ["tar.xz"] ["sha256sum"] n)) src.urls;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
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
