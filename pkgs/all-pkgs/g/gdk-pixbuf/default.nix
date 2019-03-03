{ stdenv
, fetchurl
, gettext
, lib
, makeWrapper
, meson
, ninja
, python3

, glib
, gobject-introspection
, libtiff
, libjpeg
, libpng
, libx11
, jasper
, shared-mime-info
, xorgproto

, channel
, gdk-pixbuf-loaders-cache
}:

let
  loadersCachePath = "lib/gdk-pixbuf-2.0/2.10.0";
  loadersCacheFile = "${loadersCachePath}/loaders.cache";

  sources = {
    "2.38" = {
      version = "2.38.1";
      sha256 = "f19ff836ba991031610dcc53774e8ca436160f7d981867c8c3a37acfe493ab3a";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gdk-pixbuf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gdk-pixbuf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    makeWrapper
    meson
    ninja
    python3
  ];

  buildInputs = [
    glib
    gobject-introspection
    jasper
    libjpeg
    libpng
    libtiff
    libx11
    shared-mime-info
    xorgproto
  ];

  postPatch = ''
    sed -i build-aux/gen-installed-test.py \
      -i build-aux/gen-resources.py \
      -i build-aux/gen-thumbnailer.py \
      -e 's,^#!.*,#!${python3}/bin/python3,g'
  '' + /* Fix should be included in 2.40 */ ''
    grep -q '@filename@' gdk-pixbuf/gdk-pixbuf-enum-types.h.template
    sed -i gdk-pixbuf/gdk-pixbuf-enum-types.h.template \
      -i gdk-pixbuf/gdk-pixbuf-enum-types.c.template \
      -e 's/@filename@/@basename@/g'
  '' + /* Don't generate loaders, we do this separately */ ''
    grep -q 'build-aux/post-install.sh' meson.build
    sed -i meson.build \
      -e '/build-aux\/post-install\./,+3d'
  '';

  mesonFlags = [
    "-Djasper=true"
    "-Dinstalled_tests=false"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  preFixup = ''
    wrapProgram $out/bin/gdk-pixbuf-csource \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

    wrapProgram $out/bin/gdk-pixbuf-pixdata \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

    wrapProgram $out/bin/gdk-pixbuf-thumbnailer \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"
  '';

  doCheck = false;

  passthru = {
    inherit
      loadersCacheFile
      loadersCachePath;

    loaders = gdk-pixbuf-loaders-cache;

    inherit (source) version;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls = map (u: lib.replaceStrings ["tar.xz"] ["sha256sum"] u) src.urls;;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for image loading and manipulation";
    homepage = http://library.gnome.org/devel/gdk-pixbuf/;
    license = licenses.lgpl2Plus;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
