{ stdenv
, fetchurl
, gettext
, intltool

, db
, gcr
, glib
#, gnome-online-accounts
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
, vala
, zlib
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in
stdenv.mkDerivation rec {
  name = "evolution-data-server-${version}";
  versionMajor = "3.20";
  versionMinor = "5";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/evolution-data-server/${versionMajor}/"
      + "${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/evolution-data-server/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "0d1586cd326d997497a2a6fddd939a83892be07cb20f8c88fda5013f8c5bbe7e";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    db
    gcr
    glib
    #gnome-online-accounts
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
    (enFlag "gtk" (gtk3 != null) null)
    # TODO: add google auth support
    "--disable-google-auth"
    "--disable-examples"
    # Remove dependency on webkit
    #(enFlag "goa" (gnome-online-accounts != null) null)
    "--disable-goa"
    # TODO: requires libsignon-glib (Ubuntu online accounts)
    "--disable-uoa"
    "--enable-backend-per-process"
    "--disable-backtraces"
    (enFlag "smime" (nss != null) null)
    "--enable-ipv6"
    (enFlag "weather" (libgweather != null) null)
    "--enable-dot-locking"
    "--enable-file-locking"
    "--disable-purify"
    "--enable-google"
    "--enable-largefile"
    "--enable-glibtest"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala-bindings" (vala != null) null)
    # TODO: libphonenumber support
    "--without-phonenumber"
    "--without-private-docs"
    (wtFlag "libdb" (db != null) "${db}")
    (wtFlag "krb5" (kerberos != null) "${kerberos}")
    (wtFlag "openldap" (openldap != null) null)
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
      x86_64-linux;
  };
}
