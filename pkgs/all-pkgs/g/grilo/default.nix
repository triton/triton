{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, glib
, gobject-introspection
, liboauth
, libsoup
, libxml2
, totem-pl-parser
, vala
}:

let
  channel = "0.3";
  version = "${channel}.7";
in
stdenv.mkDerivation rec {
  name = "grilo-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "ea3baf71692df177649a968635ed2bc39855c34c327274245c240f726831e9b7";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    liboauth
    libsoup
    libxml2
    totem-pl-parser
  ];

  setupHook = ./setup-hook.sh;

  mesonFlags = [
    "-Denable-test-ui=false"
    "-Denable-vala=${lib.boolTf (vala != null)}"
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
    description = "A framework for easy media discovery and browsing";
    homepage = https://wiki.gnome.org/Projects/Grilo;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
