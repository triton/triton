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
    "0.38" = {
      version = "0.38.4";
      sha256 = "2cb33a63bd17737e72f5f4f9ca4109f398500ee1f17a01ff4ef94139b07ae5e9";
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
