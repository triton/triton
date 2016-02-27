{ stdenv
, fetchurl
, gettext
, intltool

, db
, gcr
, glib
, gnome-online-accounts
, gobject-introspection
, gperf
, gsettings-desktop-schemas
, gtk3
, icu
, kerberos
, libaccounts-glib
, libgdata
, libgweather
, libical
, libsecret
, libsoup
, libxml2
, openldap
, nspr
, nss
, p11_kit
, python
, sqlite
# Optional
, vala
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "evolution-data-server-${version}";
  versionMajor = "3.18";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution-data-server/${versionMajor}/" +
          "${name}.tar.xz";
    sha256 = "0b756f05feae538676832acc122407046a89d4dd32da725789229dc3c416433f";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    db
    gcr
    glib
    gnome-online-accounts
    gobject-introspection
    gperf
    gsettings-desktop-schemas
    gtk3
    icu
    kerberos
    libaccounts-glib
    libgdata
    libgweather
    libical
    libsecret
    libsoup
    libxml2
    nspr
    nss
    openldap
    p11_kit
    python
    sqlite
    vala
    zlib
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-code-coverage"
    "--disable-installed-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-gtk"
    "--disable-examples"
    "--enable-goa"
    # TODO: requires libsignon-glib
    "--disable-uoa"
    "--enable-backend-per-process"
    "--disable-backtraces"
    "--enable-smime"
    "--enable-ipv6"
    "--enable-weather"
    "--enable-dot-locking"
    "--enable-file-locking"
    "--disable-purify"
    "--enable-google"
    "--enable-largefile"
    "--enable-glibtest"
    "--enable-introspection"
    (enFlag "vala-bindings" (vala != null) null)
    # TODO: libphonenumber support
    "--without-phonenumber"
    "--without-private-docs"
    "--with-libdb=${db}"
    "--with-krb5=${kerberos}"
    "--with-openldap"
    "--without-static-ldap"
    "--without-sunldap"
    "--without-static-sunldap"
  ];

  meta = with stdenv.lib; {
    description = "Evolution groupware backend";
    homepage = https://wiki.gnome.org/Apps/Evolution;
    license = with licenses; [
      lgpl2
      lgpl3
      bsd3
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };

}
