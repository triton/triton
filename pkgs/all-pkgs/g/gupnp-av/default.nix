{ stdenv
, fetchurl
, lib

, glib
, gobject-introspection
, gssdp
, gupnp
, libsoup
, libxml2
, vala

, channel
}:

let
  inherit (lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gupnp-av-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-av/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
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
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gupnp-av/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
