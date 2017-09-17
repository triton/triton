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
    "3.24" = {
      version = "3.24.1";
      sha256 = "76a3fa309f9de6074d66848987214f0b128124ba7184c958c15ac78a8ac7eea7";
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
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-nls"
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
