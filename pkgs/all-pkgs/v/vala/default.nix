{ stdenv
, autoreconfHook
, bison
, fetchurl
, flex
, gettext
, lib
, libxslt

, glib
, gobject-introspection
, graphviz

, channel
}:

let
  sources = {
    "0.40" = {
      version = "0.40.4";
      sha256 = "379354a2a2f7ee5c4d6e0f5e88b0e32620dcd5f51972baf6d90d9f18eb689198";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "vala-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    gettext
    libxslt
  ];

  buildInputs = [
    glib
    gobject-introspection
    graphviz
  ];

  setupHook = ./setup-hook.sh;

  postPatch = ''
    patchShebangs tests/testrunner.sh
    patchShebangs valadoc/tests/testrunner.sh
  '' + /* dbus tests require machine-id */ ''
    sed -i tests/Makefile.am \
      -e '/dbus\//d'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-unversioned"
    "--disable-coverage"
  ];

  #doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/vala/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Compiler for GObject type system";
    homepage = http://live.gnome.org/Vala;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
