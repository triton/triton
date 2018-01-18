{ stdenv
, fetchurl
, gettext
, intltool
, lib
, perl

, bzip2
, gdk-pixbuf
, glib
, gobject-introspection
, imagemagick
, libxml2
, python
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "1.14" = {
      version = "1.14.42";
      sha256 = "29fffb87b278b3fb1b8ae9138c3b4529c1fce664f1f94297c146a8563df80dc2";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgsf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgsf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ] ++ optionals doCheck [
    perl
  ];

  buildInputs = [
    bzip2
    gdk-pixbuf
    glib
    gobject-introspection
    libxml2
    python
    zlib
  ] ++ optionals (gdk-pixbuf == null) [
    imagemagick
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-gir-dir=$out/share/gir-1.0"
      "--with-typelib-dir=$out/lib/girepository-1.0"
    )
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolWt (zlib != null)}-zlib"
    "--${boolWt (bzip2 != null)}-bz2"
    "--${boolEn (gdk-pixbuf != null)}-gdk-pixbuf"
  ];

  preCheck = "patchShebangs ./tests/";

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgsf/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GNOME's Structured File Library";
    homepage = https://www.gnome.org/projects/libgsf;
    license = with licenses; [
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
