{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib
, gobject-introspection
, python3Packages
, sqlite
}:

let
  channel = "0.3";
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "gom-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gom/${channel}/${name}.tar.xz";
    sha256 = "1zaqqwwkyiswib3v1v8wafpbifpbpak0nn2kp13pizzn9bwz1s5w";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    python3Packages.python
    python3Packages.pygobject
    sqlite
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-pythondir=$out/${python3Packages.python.sitePackages}"
    )
  '';

  configureFlags = [
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--enable-python"
  ];

  doCheck = true;

  meta = with lib; {
    description = "GObject to SQLite object mapper library";
    homepage = https://wiki.gnome.org/Projects/Gom;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
