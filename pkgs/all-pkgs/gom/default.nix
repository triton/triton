{ stdenv
, fetchurl
, gettext
, intltool

, glib
, gobject-introspection
, python3
, python3Packages
, sqlite
}:

with {
  inherit (stdenv.lib)
    enFlag
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gom-${version}";
  versionMajor = "0.3";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gom/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "1zaqqwwkyiswib3v1v8wafpbifpbpak0nn2kp13pizzn9bwz1s5w";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    python3
    python3Packages.pygobject3
    sqlite
  ];

  configureFlags = [
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-debug"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "python" (python3 != null) null)
    (wtFlag "pythondir" (python3 != null) "\${out}/lib/${python3.libPrefix}/site-packages")
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "GObject to SQLite object mapper library";
    homepage = https://wiki.gnome.org/Projects/Gom;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
