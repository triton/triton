{ stdenv
, fetchurl
, intltool
, itstool
, libtool
, makeWrapper

, adwaita-icon-theme
, atk
, bogofilter
, cairo

, dconf
, db
, enchant
, evolution-data-server
, gcr
, gdk-pixbuf
, glib
, gnome-desktop
, gnome-themes-standard
, gsettings-desktop-schemas
, gst-plugins-base
, gstreamer
, gtk3
, gtkhtml
, gtkspell
, highlight
, icu
, libcanberra
, libgdata
, libgweather
, libical
, libnotify
, librsvg
, libsecret
, libsoup
, libxml2
, nspr
, nss
, p11_kit
, procps
, shared-mime-info
, sqlite
}:

stdenv.mkDerivation rec {
  name = "evolution-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/evolution/${versionMajor}/${name}.sha256sum";
    sha256 = "029567e20fa62263c5fcd2e7f3a0dff96364b647cf9d36a5b99a3abe3b0027d3";
  };

  propagatedUserEnvPkgs = [
    gnome-themes-standard
  ];

  nativeBuildInputs = [
    intltool
    itstool
    libtool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    bogofilter
    cairo
    dconf
    db
    enchant
    evolution-data-server
    gcr
    gdk-pixbuf
    glib
    gnome-desktop
    gsettings-desktop-schemas
    gst-plugins-base
    gstreamer
    gtk3
    gtkhtml
    gtkspell
    highlight
    icu
    libcanberra
    libgdata
    libgweather
    libical
    libnotify
    librsvg
    libsecret
    libsoup
    libxml2
    nspr
    nss
    p11_kit
    procps
    shared-mime-info
    sqlite
  ];

  configureFlags = [
    "--disable-spamassassin"
    "--disable-pst-import"
    "--disable-autoar"
    "--disable-libcryptui"
  ];

  preFixup = ''
    wrapProgram $out/bin/evolution \
      --set 'GDK_PIXBUF_MODULE_FILE' "${gdk-pixbuf.loaders.cache}" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Integrated mail, calendaring and address book";
    homepage = https://wiki.gnome.org/Apps/Evolution;
    license = licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = with platforms;
      x86_64-linux;
    # evolution does not support webkit-2.10+
    broken = true;
  };
}
