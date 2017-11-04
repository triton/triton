{ stdenv
, autoreconfHook
, fetchFromGitHub
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

    version = "2017-11-03";
in
stdenv.mkDerivation rec {
  name = "libgda-${version}";

  # A release has not been tagged since 2015
  src = fetchFromGitHub {
    version = 3;
    owner = "GNOME";
    repo = "libgda";
    rev = "567e359987e18128eaa824062f64218734aef200";
    sha256 = "910feac0605341b869bdd105eae15f024c0a5e4d404ff03f58b977c2998ae83f";
  };

  nativeBuildInputs = [
    autoreconfHook
    gnome-common
    gtk-doc
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

  autoreconfPhase = ''
    sed -i autogen.sh -e 's/which/type/'
    ./autogen.sh
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
