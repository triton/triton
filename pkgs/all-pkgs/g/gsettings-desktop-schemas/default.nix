{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib
, gnome-backgrounds
, gobject-introspection

, channel
}:

let
  inherit (lib)
    boolEn;

  sources ={
    "3.28" = {
      version = "3.28.1";
      sha256 = "f88ea6849ffe897c51cfeca5e45c3890010c82c58be2aee18b01349648e5502f";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "gsettings-desktop-schemas-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gsettings-desktop-schemas/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  postPatch = ''
    sed -i schemas/org.gnome.desktop.{background,screensaver}.gschema.xml.in \
      -e 's|@datadir@|${gnome-backgrounds}/share/|'
  '';

  configureFlags = [
    "--disable-schemas-compile"
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/"
          + "gsettings-desktop-schemas/${channel}/${name}.sha256sum";
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Collection of GSettings schemas for GNOME desktop";
    homepage = https://git.gnome.org/browse/gsettings-desktop-schemas;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
