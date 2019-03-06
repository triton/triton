{ stdenv
, fetchurl
, intltool
, lib

, libxml2
, gcr
, glib
, json-glib
#, gnome-online-accounts
, gobject-introspection
, liboauth
, libsoup
, vala
}:

let
  inherit (lib)
    boolEn;

  channel = "0.17";
  version = "${channel}.9";
in
stdenv.mkDerivation rec {
  name = "libgdata-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgdata/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "85c4f7674c0098ffaf060ae01b6b832cb277b3673d54ace3bdedaad6b127453a";
  };

  nativeBuildInputs = [
    intltool
    vala
  ];

  buildInputs = [
    gcr
    glib
    #gnome-online-accounts
    gobject-introspection
    json-glib
    liboauth
    libsoup
    libxml2
  ];

  configureFlags = [
    "--disable-gtk"
    "--enable-gnome"
    "--disable-goa"  # FIXME
    "--disable-always-build-tests"
    "--enable-introspection"
    "--${boolEn (vala != null)}-vala"
  ];

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
    description = "GLib library for online service APIs using the GData protocol";
    homepage = https://wiki.gnome.org/Projects/libgdata;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
