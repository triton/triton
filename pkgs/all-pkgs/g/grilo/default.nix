{ stdenv
, fetchurl
, file
, gettext
, intltool
, lib
#, meson
#, ninja

, glib
, gobject-introspection
, liboauth
, libsoup
, libxml2
, totem-pl-parser
, vala
}:

let
  inherit (lib)
    boolEn;

  channel = "0.3";
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "grilo-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "7c6964053b42574c2f14715d2392a02ea5cbace955eb73e067c77aa3e43b066e";
  };

  nativeBuildInputs = [
    file
    gettext
    intltool
    #meson
    #ninja
  ];

  buildInputs = [
    glib
    gobject-introspection
    liboauth
    libsoup
    libxml2
    totem-pl-parser
    vala
  ];

  setupHook = ./setup-hook.sh;

  configureFlags = [
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-maintainer-mode"
    "--disable-test-ui"
    "--enable-grl-net"
    "--${boolEn (totem-pl-parser != null)}-grl-pls"
    "--disable-debug"
    # Flag is not a boolean
    #"--disable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--enable-nls"
  ];

  # mesonFlags = [
  #   "-Denable-grl-net=true"
  #   "-Denable-grl-pls=${boolTf (totem-pl-parser != null)}"
  #   "-Denable-gtk-doc=false"
  #   "-Denable-introspection=${boolTf (gobject-introspection != null)}"
  #   "-Denable-test-ui=false"
  #   "-Denable-vala=${boolTf (vala != null)}"
  # ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/grilo/${channel}/"
        + "${name}.sha256sum";
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
