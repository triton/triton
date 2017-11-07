{ stdenv
, fetchurl
, gettext
, intltool
, lib

, atk
, gconf
, gdk-pixbuf
, geocode-glib
, glib
, gobject-introspection
, gtk
, libsoup
, libxml2
, pango
, tzdata
, vala

, channel
}:

let
  inherit (lib)
    boolEn
    boolString
    boolWt;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "libgweather-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgweather/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    vala
  ];

  buildInputs = [
    atk
    gconf
    gdk-pixbuf
    geocode-glib
    glib
    gobject-introspection
    gtk
    libsoup
    libxml2
    pango
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--enable-compile-warnings"
    #"--disable-Werror"
    "--enable-glibtest"
    "--enable-nls"
    "--disable-glade-catalog"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--${boolWt (tzdata != null)}-zoneinfo-dir${
      boolString (tzdata != null) "=${tzdata}/share/zoneinfo" ""}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgweather/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library to access weather information from online services";
    homepage = https://wiki.gnome.org/Projects/LibGWeather;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
