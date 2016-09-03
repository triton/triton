{ stdenv
, fetchurl
, gettext
, intltool

, bzip2
, gdk-pixbuf_unwrapped
, glib
, gobject-introspection
, imagemagick
, libxml2
, python
, zlib

, perl

, channel ? "1.14"
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "libgsf-${channel}.39";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/libgsf/${channel}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/libgsf/${channel}/${name}.sha256sum";
    sha256 = "3dcfc911438bf6fae5fe842e85a9ac14324d85165bd4035caad4a4420f15a175";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ] ++ optionals doCheck [
    perl
  ];

  buildInputs = [
    bzip2
    gdk-pixbuf_unwrapped
    glib
    gobject-introspection
    libxml2
    python
    zlib
  ] ++ optionals (gdk-pixbuf_unwrapped == null) [
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
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--with-zlib"
    "--with-bz2"
    (wtFlag "gdk-pixbuf" (gdk-pixbuf_unwrapped != null) null)
  ];

  preCheck = "patchShebangs ./tests/";

  doCheck = true;

  meta = with stdenv.lib; {
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
