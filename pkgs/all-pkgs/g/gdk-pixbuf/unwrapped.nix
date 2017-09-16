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

  sources = {
    "2.36" = {
      version = "2.36.10";
      sha256 = "f8f6fa896b89475c73b6e9e8d2a2b062fc359c4b4ccb8e96470d6ab5da949ace";
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
