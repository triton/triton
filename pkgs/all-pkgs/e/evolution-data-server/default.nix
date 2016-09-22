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
, gtk
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

, channel
}:

let
  inherit (stdenv.lib)
    boolEn
    boolString
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "evolution-data-server-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution-data-server/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    gtk
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
    "--${boolEn (gtk != null)}-gtk"
    # TODO: add google auth support
    "--disable-google-auth"
    "--disable-examples"
    # Remove dependency on webkit
    #"--${boolEn }-goa" (gnome-online-accounts != null) null)
    "--disable-goa"
    # TODO: requires libsignon-glib (Ubuntu online accounts)
    "--disable-uoa"
    "--enable-backend-per-process"
    "--disable-backtraces"
    "--${boolEn (nss != null)}-smime"
    "--enable-ipv6"
    "--${boolEn (libgweather != null)}-weather"
    "--enable-dot-locking"
    "--enable-file-locking"
    "--disable-purify"
    "--enable-google"
    "--enable-largefile"
    "--enable-glibtest"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala-bindings"
    # TODO: libphonenumber support
    "--without-phonenumber"
    "--without-private-docs"
    "--${boolWt (db != null)}-libdb${boolString (db != null) "=${db}" ""}"
    "--${boolWt (kerberos != null)}-krb5${
      boolString (kerberos != null) "=${kerberos}" ""}"
    "--${boolWt (openldap != null)}-openldap"
    "--without-static-ldap"
    "--without-sunldap"
    "--without-static-sunldap"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/evolution-data-server/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

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
