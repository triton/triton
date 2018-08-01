{ stdenv
, fetchurl

, glib
, gobject-introspection
, gssdp
, libsoup
, libxml2
, util-linux_lib
, vala
}:

let
  major = "1.0";
  version = "${major}.3";
in
stdenv.mkDerivation rec {
  name = "gupnp-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${major}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "794b162ee566d85eded8c3f3e8c9c99f6b718a6b812d8b56f0c2ed72ac37cbbb";
  };

  nativeBuildInputs = [
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    libsoup
    libxml2
    util-linux_lib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    #--with-context-manager=[network-manager/connman/unix/linux]
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gupnp/${major}/"
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
