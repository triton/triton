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
      version = "3.28.0";
      sha256 = "4cb4cd7790b77e5542ec75275237613ad22f3a1f2f41903a298cf6cc996a9167";
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
    "--enable-schemas-compile"
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/"
        + "gsettings-desktop-schemas/${channel}/${name}.sha256sum";
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
