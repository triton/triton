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
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gupnp-av/${versionMajor}/${name}.tar.xz";
    sha256 = "759bc7d46aff894c282d17f508d9b5be82de96aa74b10cb6b0fc6c5e07cc273c";
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
