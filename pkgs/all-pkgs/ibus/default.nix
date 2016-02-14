{ stdenv
, fetchurl
, intltool
, makeWrapper

, atk
, dbus
, dconf
, gconf
, glib
, gobject-introspection
, gtk2
, gtk3
, isocodes
, libnotify
, libxkbcommon
, pygobject
, python3
, vala
, wayland
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "ibus-${version}";
  version = "1.5.12";

  src = fetchurl {
    url = "https://github.com/ibus/ibus/releases/download/${version}/${name}.tar.gz";
    sha256 = "0b24w95v77ygkcdv1s9jqza5mp47jiqbmsjrcfwsbb7ljmcsjkg2";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    glib
    dbus
    dconf
    gconf
    gobject-introspection
    gtk2
    gtk3
    isocodes
    libnotify
    libxkbcommon
    python3
    vala
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-glibtest"
    "--disable-tests"
    (enFlag "gtk2" (gtk2 != null) null)
    (enFlag "gtk3" (gtk3 != null) null)
    "--enable-xim"
    (enFlag "wayland" (wayland != null) null)
    "--enable-appindicator"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-gconf"
    "--enable-schemas-install"
    (enFlag "python-library" (python3 != null) null)
    "--enable-setup"
    (enFlag "dbus-python-check" (python3 != null) null)
    "--enable-key-snooper"
    "--enable-surrounding-text"
    "--enable-ui"
    "--enable-engine"
    "--enable-libnotify"
    "--with-python=${python3.interpreter}"
  ];

  preConfigure = ''
    substituteInPlace data/dconf/Makefile.in \
      --replace "dconf update" "echo"
    sed -i configure \
      -e "s|PYTHON2_LIBDIR=.*|PYTHON2_LIBDIR=$out/lib/${python3.libPrefix}|"
  '';

  preFixup = ''
    for f in "$out"/bin/* ; do
      wrapProgram "$f" \
        --prefix XDG_DATA_DIRS : "$out/share:$GSETTINGS_SCHEMAS_PATH" \
        --prefix PYTHONPATH : "$(toPythonPath ${pygobject})" \
        --prefix LD_LIBRARY_PATH : "${gtk3}/lib:${atk}/lib:$out/lib" \
        --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH:$out/lib/girepository-1.0" \
        --prefix GIO_EXTRA_MODULES : "${dconf}/lib/gio/modules"
    done
  '';

  meta = with stdenv.lib; {
    description = "Intelligent Input Bus for Linux / Unix OS";
    homepage = https://github.com/ibus/ibus/wiki;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
