{ stdenv
, docbook-xsl
, docbook-xsl-ns
, fetchurl
, gettext
, intltool
, libxslt
, makeWrapper

, dbus
, dbus-glib
, glib
, gtk3
, libxml2
, vala

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "dconf-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gtk3
    libxml2
    vala
  ];

  configureFlags = [
    "--disable-man"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-gcov"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/dconf/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Simple low-level configuration system";
    homepage = https://wiki.gnome.org/dconf;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
