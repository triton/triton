{ stdenv
, fetchurl
, gettext
, lib
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

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  loadersCachePath = "lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

  sources = {
    "2.36" = {
      version = "2.36.11";
      sha256 = "ae62ab87250413156ed72ef756347b10208c00e76b222d82d9ed361ed9dde2f3";
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
  ];

  inherit loadersCachePath;

  postPatch = ''
    sed -i build-aux/gen-installed-test.py \
      -i build-aux/gen-resources.py \
      -i build-aux/gen-thumbnailer.py \
      -e 's,^#!.*,#!${python3}/bin/python3,g'
  '' + /* Remove hardcoded references to build directory */ ''
    sed -i gdk-pixbuf/gdk-pixbuf-enum-types.h.template \
      -e '/@filename@/d'
  '';

  mesonFlags = [
    "-Denable_png=true"
    "-Denable_tiff=true"
    "-Denable_jpeg=true"
    "-Denable_jasper=true"
    "-Dbuiltin_loaders=all"
    "-Dwith_docs=false"
    "-Dwith_gir=true"
    "-Dwith_man=false"
    "-Denable_relocatable=false"
    "-Denable_native_windows_loaders=false"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  doCheck = false;

  passthru = {
    inherit loadersCachePath;

    inherit (source) version;

    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gdk-pixbuf/${channel}/"
        + "${name}.sha256sum";
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
