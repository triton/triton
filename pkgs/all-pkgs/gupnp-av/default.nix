{ stdenv
, fetchurl

, glib
, gobject-introspection
, gssdp
, gupnp
, libsoup
, libxml2
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gupnp-av-${version}";
  versionMajor = "0.12";
  versionMinor = "7";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-av/${versionMajor}/${name}.tar.xz";
    sha256 = "35e775bc4f7801d65dcb710905a6b8420ce751a239b5651e6d830615dc906ea8";
  };

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    gupnp
    libsoup
    libxml2
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  meta = with stdenv.lib; {
    description = "Utility library to ease the handling UPnP A/V profiles";
    homepage = http://gupnp.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
