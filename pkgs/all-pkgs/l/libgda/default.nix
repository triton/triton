{ stdenv
, autoreconfHook
, fetchurl
, gnome-common
, gtk-doc
, intltool
, itstool
, lib

, atk
, db
#, firebird
, gdk-pixbuf
, glib
, gobject-introspection
, graphviz
, gtk3
, gtksourceview
, iso-codes
, json-glib
, libgee
, libsecret
, libsoup
, libxml2
, libxslt
, mariadb-connector-c
, ncurses
, openldap
, openssl
, pango
, postgresql
, readline
, sqlite
, vala
}:

let
  inherit (lib)
    boolEn
    boolWt;

  channel = "5.2";
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "libgda-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgda/${channel}/${name}.tar.xz";
    sha256 = "2cee38dd583ccbaa5bdf6c01ca5f88cc08758b9b144938a51a478eb2684b765e";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    itstool
  ];

  buildInputs = [
    atk
    db
    #firebird
    #gdk-pixbuf  # ui
    glib
    gobject-introspection
    #graphviz  # ui
    #gtk3  # ui
    #gtksourceview  # ui
    iso-codes
    json-glib
    libgee
    libsecret
    libsoup
    libxml2
    libxslt
    mariadb-connector-c
    ncurses
    openldap
    openssl
    pango
    postgresql
    readline
    sqlite
    vala
  ];

  postPatch = /* Fix building against newer versions of vala */ ''
    sed -i configure.ac \
      -e 's/\[0\.26\.0\]//g' \
      -e 's/\[0\.26\]//g' \
      -e 's/vala_api="0.26/vala_api="`pkg-config --modversion vapigen`/'
  '' + /* Remove non-UTF-8 (ISO-8859-16) strings
          See: 12429af2c0a40bb199ced605b7f7fab5ecc77e86 */ ''
    for nonutf8 in */*.h */*/*.h */*/*/*.h; do
      sed -i "$nonutf8" \
        -e '/Copyright (C)/ s/\*.*$/*/g'
    done
  '';

  configureFlags = [
    "--enable-nls"
    "--disable-tools"  # ui
    "--enable-json"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (gobject-introspection != null)}-gda-gi"
    #"--${boolEn (gobject-introspection != null)}-gdaui-gi"
    "--disable-gda-ui"  # ui
    "--${boolEn (gobject-introspection != null)}-gi-system-install"
    #"--${boolEn (vala != null)}-gdaui-vala"
    "--${boolEn (vala != null)}-vala-extensions"
    "--${boolEn (vala != null)}-vala"
    "--${boolEn (openssl != null)}-crypto"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-system-mdbtools"
    "--enable-rpath"
    "--disable-debug"
    "--disable-mutex-debug"
    "--disable-rebuilds"
    "--enable-default-binary"
    "--enable-warnings"
    "--without-ui"  # ui
    #"--${boolWt (gtksourceview != null)}-gtksourceview"
    "--without-gtksourceview"  # ui
    # TODO: goocanvas
    "--disable-goocanvas"  # ui
    #"--${boolWt (graphviz != null)}-graphviz"
    "--without-graphviz"  # ui
    "--${boolWt (db != null)}-bdb"
    "--${boolWt (mariadb-connector-c != null)}-mysql"
    "--${boolWt (postgresql != null)}-postgres"
    "--without-oracle"
    # TODO: java support
    "--disable-java"
    "--with-jni"
    "--${boolWt (openldap != null)}-ldap"
    # TODO: firebird support
    "--disable-firebird"
    "--without-mdb"
    "--${boolWt (libsoup != null)}-libsoup"
    "--${boolWt (libsecret != null)}-libsecret"
    #"--${boolWt (gnome-keyring != null)}-gnome-keyring"
    "--with-gnome-keyring"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-implicit-function-declaration"  # gcc7
    "-Wno-int-to-pointer-cast"  # gcc7
  ];

  preInstall = ''
    installFlagsArray+=(
      "girdir=$out/share/gir-1.0/"
      "typelibsdir=$out/lib/girepository-1.0"
    )
  '';

  meta = with lib; {
    description = "GNOME database access library";
    homepage = https://wiki.gnome.org/Projects/libgdata;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
