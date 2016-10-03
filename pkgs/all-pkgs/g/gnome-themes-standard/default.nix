{ stdenv
, fetchurl
, gettext
, intltool
, lib

, adwaita-icon-theme
, cairo
, gdk-pixbuf
, glib
, gtk_2
, gtk
, librsvg

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-themes-standard-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-themes-standard/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    adwaita-icon-theme
    cairo
    gdk-pixbuf
    glib
    gtk_2
    gtk
    librsvg
  ];

  configureFlags = [
    "--enable-glibtest"
    "--enable-nls"
    "--${boolEn (gtk != null)}-gtk3-engine"
    "--${boolEn (gtk_2 != null)}-gtk2-engine"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-themes-standard/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Standard Themes for GNOME Applications";
    homepage = https://git.gnome.org/browse/gnome-themes-standard/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
