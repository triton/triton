{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib
, gobject-introspection
, vala
, zlib
}:

let
  channel = "0.7";
  version = "${channel}";
in
stdenv.mkDerivation rec {
  name = "gcab-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gcab/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a16e5ef88f1c547c6c8c05962f684ec127e078d302549f3dfd2291e167d4adef";
  };

  nativeBuildInputs = [
    gettext
    intltool
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--enable-nls"
    "--enable-glibtest"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gcab/${versionMajor}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Library and tool for Microsoft Cabinet (CAB) files";
    homepage = https://wiki.gnome.org/msitools;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
