{ stdenv
, fetchurl
, lib
, meson
, ninja

, glib
, gobject-introspection
, gtk
, libsoup
, vala
}:

# FIXME: add makeWrapper for graphical utility.

let
  channel = "1.0";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gssdp-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "211387a62bc1d99821dd0333d873a781320287f5436f91e58b2ca145b378be41";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    gtk
    libsoup
  ];

  mesonFlags = [
    "-Dexamples=false"
  ];

  setVapidirInstallFlag = false;

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
