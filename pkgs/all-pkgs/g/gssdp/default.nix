{ stdenv
, fetchurl

, glib
, gobject-introspection
, gtk
, libsoup
, vala
}:

let
  major = "1.0";
  version = "${major}.2";
in
stdenv.mkDerivation rec {
  name = "gssdp-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${major}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a1e17c09c7e1a185b0bd84fd6ff3794045a3cd729b707c23e422ff66471535dc";
  };

  nativeBuildInputs = [
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    gtk
    libsoup
  ];

  configureFlags = [
    "--disable-maintainer-mode"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gssdp/${major}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "GObject-based API for resource discovery over SSDP";
    homepage = https://wiki.gnome.org/Projects/GUPnP;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
