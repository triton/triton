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

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gupnp-av-${version}";
  versionMajor = "0.12";
  versionMinor = "9";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-av/${versionMajor}/${name}.tar.xz";
    sha256 = "62c56449256a1a97b66c8ee59aa6455b90a7921285745ef3b79566218e85d447";
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
    platforms = with platforms;
      x86_64-linux;
  };
}
