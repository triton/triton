{ stdenv
, fetchurl
, gettext
, intltool
, lib

, gdk-pixbuf
, hicolor-icon-theme

, channel
}:

let
  sources = {
    "3.26" = {
      version = "3.26.1";
      sha256 = "28ba7392c7761996efd780779167ea6c940eedfb1bf37cfe9bccb7021f54d79d";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "adwaita-icon-theme-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/adwaita-icon-theme/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  propagatedBuildInputs = [
    # FIXME
    # For convenience, we specify adwaita-icon-theme only in packages
    hicolor-icon-theme
  ];

  buildInputs = [
    gdk-pixbuf
  ];

  configureFlags = [
    "--enable-l-xl-variants"
  ];

  preInstall = ''
    # Install fails to create these directories automatically
    mkdir -pv $out/share/icons/Adwaita-{,Extra}Large/cursors
  '';

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/adwaita-icon-theme/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "GNOME default icon theme";
    homepage = https://git.gnome.org/browse/adwaita-icon-theme/;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
