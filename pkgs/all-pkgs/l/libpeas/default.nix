{ stdenv
, fetchurl
, gettext
, intltool
, lib

, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gtk_3
, pango
, python3Packages

, ncurses

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libpeas-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libpeas/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs =  [
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gtk_3
    pango
    python3Packages.pygobject3
    python3Packages.python
  ] ++ [
    # Fix ncurses not being detected via python3.6's pkgconfig path
    ncurses
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--${boolEn (gtk_3 != null)}-gtk"
    # Flag is not a Boolean
    #"--disable-gcov"
    "--disable-glade-catalog"
    "--disable-lua5.1"
    "--disable-luajit"
    "--disable-python2"
    "--${boolEn (python3Packages.python != null)}-python3"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doc-cross-references"
    "--enable-compile-warnings"
    "--disable-iso-c"
  ];

  # FIXME
  buildDirCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libpeas/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A GObject plugins library";
    homepage = "https://developer.gnome.org/libpeas/stable/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
