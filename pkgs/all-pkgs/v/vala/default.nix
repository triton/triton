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

, channel
}:

let
  sources = {
    "0.36" = {
      version = "0.36.4";
      sha256 = "e9f23ce711c1a72ce664d10946fbc5953f01b0b7f2a3562e7a01e362d86de059";
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
  ];

  setupHook = ./setup-hook.sh;

  postPatch = ''
    patchShebangs ./tests/testrunner.sh
  '' + /* dbus tests require machine-id */ ''
    sed -i tests/Makefile.am \
      -e '/dbus\//d'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-unversioned"
    "--disable-coverage"
  ];

  doCheck = true;

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
