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

  sources = {
    "3.22" = {
      version = "3.22.3";
      sha256 = "61dc87c52261cfd5b94d65e8ffd923ddeb5d3944562f84942eeeb197ab8ab56a";
    };
  };

  source = sources."${channel}";
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

  setupHook = ./setup-hook.sh;

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
