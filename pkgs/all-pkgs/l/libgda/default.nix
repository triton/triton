{ stdenv
, fetchurl
, intltool
, itstool

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
#, vala
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;

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
    intltool
    itstool
  ];

  buildInputs = [
    atk
    db
    #firebird
    gdk-pixbuf
    glib
    gobject-introspection
    graphviz
    gtk3
    gtksourceview
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
    #vala
  ];

  configureFlags = [
    "--enable-nls"
    "--enable-tools"
    "--enable-json"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "gda-gi" (gobject-introspection != null) null)
    (enFlag "gdaui-gi" (gobject-introspection != null) null)
    (enFlag "gi-system-install" (gobject-introspection != null) null)
    #(enFlag "gdaui-vala" (vala != null) null)
    #(enFlag "vala-extensions" (vala != null) null)
    #(enFlag "vala" (vala != null) null)
    (enFlag "crypto" (openssl != null) null)
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
    "--with-ui"
    (wtFlag "gtksourceview" (gtksourceview != null) null)
    # TODO: goocanvas
    "--disable-goocanvas"
    (wtFlag "graphviz" (graphviz != null) null)
    (wtFlag "bdb" (db != null) null)
    (wtFlag "mysql" (mariadb-connector-c != null) null)
    (wtFlag "postgres" (postgresql != null) null)
    "--without-oracle"
    # TODO: java support
    "--disable-java"
    "--with-jni"
    (wtFlag "ldap" (openldap != null) null)
    # TODO: firebird support
    "--disable-firebird"
    "--without-mdb"
    (wtFlag "libsoup" (libsoup != null) null)
    (wtFlag "libsecret" (libsecret != null) null)
    #(wtFlag "gnome-keyring" (gnome-keyring != null) null)
    "--with-gnome-keyring"
  ];

  preInstall = ''
    installFlagsArray+=(
      "girdir=$out/share/gir-1.0/"
      "typelibsdir=$out/lib/girepository-1.0"
    )
  '';

  meta = with stdenv.lib; {
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
