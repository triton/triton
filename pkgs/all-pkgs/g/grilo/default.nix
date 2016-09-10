{ stdenv
, fetchurl
, file
, gettext
, intltool

, glib
, gobject-introspection
, liboauth
, libsoup
, libxml2
, totem-pl-parser
, vala
}:

let
  inherit (stdenv.lib)
    boolEn;

  channel = "0.3";
  version = "0.3.2";
in
stdenv.mkDerivation rec {
  name = "grilo-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f26f684a5d76aea8dbce136750bc67d2170b36575f109292fbb78ae99ec87f5b";
  };

  nativeBuildInputs = [
    file
    gettext
    intltool
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

  meta = with stdenv.lib; {
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
