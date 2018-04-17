{ stdenv
, fetchurl
, intltool
, lib
, makeWrapper

, atk
, dbus
, dconf
, gconf
, glib
, gobject-introspection
, gtk_2
, gtk_3
, iso-codes
, json-glib
, libnotify
, libx11
, libxext
, libxfixes
, libxi
, libxkbcommon
, python3Packages
, unicode-character-database
, vala
, wayland
, xorg
}:

let
  inherit (lib)
    boolEn;

  version = "1.5.18";
in
stdenv.mkDerivation rec {
  name = "ibus-${version}";

  src = fetchurl {
    url = "https://github.com/ibus/ibus/releases/download/${version}/"
      + "${name}.tar.gz";
    sha256 = "8551f7d027fb65d48225642fc8f3b232412ea75a4eb375244dd72a4d73c2639e";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
    vala
  ];

  buildInputs = [
    glib
    dbus
    dconf
    gconf
    gobject-introspection
    gtk_2
    gtk_3
    iso-codes
    json-glib
    libnotify
    libx11
    libxext
    libxfixes
    libxi
    libxkbcommon
    python3Packages.python
    unicode-character-database
    wayland
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-glibtest"
    "--disable-tests"
    "--${boolEn (gtk_2 != null)}-gtk2"
    "--${boolEn (gtk_3 != null)}-gtk3"
    "--enable-xim"
    "--${boolEn (wayland != null)}-wayland"
    "--enable-appindicator"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-gconf"
    "--enable-schemas-install"
    "--disable-memconf"
    "--${boolEn (dconf != null)}-dconf"
    "--disable-schemas-compile"
    "--${boolEn (python3Packages.python != null)}-python-library"
    "--enable-setup"
    "--${boolEn (python3Packages.python != null)}-dbus-python-check"
    "--enable-key-snooper"
    "--enable-surrounding-text"
    "--enable-ui"
    "--enable-engine"
    "--enable-libnotify"
    "--disable-emoji-dict"
    "--with-python=${python3Packages.python.interpreter}"
  ];

  preConfigure = ''
    sed -i data/dconf/Makefile.in \
      -e 's/dconf update/echo/'
    sed -i configure \
      -e "s|PYTHON2_LIBDIR=.*|PYTHON2_LIBDIR=$out/lib/${
        python3Packages.python.libPrefix}|"
  '' + /* Upstream does not correctly implement autoconf flags */ ''
    sed -i configure \
      -e 's,/usr/share/unicode/ucd,${unicode-character-database}/share/unicode-character-database,g'
  '';

  preFixup = ''
    for f in "$out"/bin/* ; do
      wrapProgram "$f" \
        --prefix XDG_DATA_DIRS : "$out/share:$GSETTINGS_SCHEMAS_PATH" \
        --prefix PYTHONPATH : "$(toPythonPath ${python3Packages.pygobject})" \
        --prefix LD_LIBRARY_PATH : "${gtk_3}/lib:${atk}/lib:$out/lib" \
        --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH:$out/lib/girepository-1.0" \
        --prefix GIO_EXTRA_MODULES : "${dconf}/lib/gio/modules"
    done
  '';

  meta = with lib; {
    description = "Intelligent Input Bus for Linux / Unix OS";
    homepage = https://github.com/ibus/ibus/wiki;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
