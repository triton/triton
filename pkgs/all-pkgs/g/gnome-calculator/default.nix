{ stdenv
, fetchurl
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, glib
, gmp
, gnome-themes-standard
, gsettings-desktop-schemas
, gtk
, gtksourceview
, librsvg
, libsoup
, libxml2
, mpfr
, shared-mime-info

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-calculator-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-calculator/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  propagatedUserEnvPkgs = [
    gnome-themes-standard
  ];

  nativeBuildInputs = [
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    gdk-pixbuf
    glib
    gmp
    gsettings-desktop-schemas
    gtk
    gtksourceview
    librsvg
    libsoup
    libxml2
    mpfr
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-nls"
    "--disable-installed-tests"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-calculator \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$out/share"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-calculator/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A calculator application for GNOME";
    homepage = https://wiki.gnome.org/Apps/Calculator;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
