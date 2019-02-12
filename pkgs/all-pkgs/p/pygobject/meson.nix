{ stdenv
, fetchurl
, lib
, pkgs

, cairo
, glib
, gobject-introspection
, libffi
, pycairo
, python

, channel
, nocairo ? false
}:

let
  inherit (lib)
    boolTf
    optionals;

  sources = {
    "3.30" = {
      version = "3.30.1";
      sha256 = "e1335b70e36885bf1ae207ec1283a369b8fc3e080688046c1edb5a676edc11ce";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "pygobject-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pygobject/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
  ];

  buildInputs = [
    glib
    gobject-introspection
    libffi
  ] ++ optionals (!nocairo) [
    cairo
    pycairo
  ];

  mesonFlags = [
    "-Dpycairo=${boolTf (!nocairo)}"
    "-Dpython=${python.interpreter}"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      fullOpts = {
        sha256Url = "https://download.gnome.org/sources/pygobject/${channel}/"
          + "${name}.sha256sum";
      };
    };
  };

  meta = with lib; {
    description = "Python Bindings for GLib/GObject/GIO/GTK+";
    homepage = https://wiki.gnome.org/action/show/Projects/PyGObject;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
