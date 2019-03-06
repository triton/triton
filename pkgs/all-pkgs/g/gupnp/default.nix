{ stdenv
, fetchurl
, lib
#, meson
#, ninja

, glib
, gobject-introspection
, gssdp
, libsoup
, libxml2
, linux-headers
, util-linux_lib
, vala
}:

let
  channel = "1.0";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gupnp-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "794b162ee566d85eded8c3f3e8c9c99f6b718a6b812d8b56f0c2ed72ac37cbbb";
  };

  nativeBuildInputs = [
    #meson
    #ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    gssdp
    libsoup
    libxml2
    linux-headers
    util-linux_lib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--with-context-manager=linux"
  ];

  #mesonFlags = [
  #  "-Dcontext_manager=linux"
  #  "-Dexamples=false"
  #];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls =
          map (u: lib.replaceStrings ["tar.xz"] ["sha256sum"] u) src.urls;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "An implementation of the UPnP specification";
    homepage = http://www.gupnp.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
