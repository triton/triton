{ stdenv
, fetchurl

, glib
, gobject-introspection
, gssdp
, libsoup
, libxml2
, util-linux_lib
, vala

, channel
}:

let
  inherit (stdenv.lib)
    boolEn;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gupnp-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    libsoup
    libxml2
    util-linux_lib
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-largefile"
    "--enable-compile-warnings"
    "--disable-Werror"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    #--with-context-manager=[network-manager/connman/unix/linux]
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gupnp/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "An implementation of the UPnP specification";
    homepage = http://www.gupnp.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
