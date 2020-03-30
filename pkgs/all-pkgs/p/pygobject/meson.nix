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
    "3.36" = {
      version = "3.36.0";
      sha256 = "8683d2dfb5baa9e501a9a64eeba5c2c1117eadb781ab1cd7a9d255834af6daef";
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
    "-Dtests=false"
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
