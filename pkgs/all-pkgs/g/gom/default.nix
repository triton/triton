{ stdenv
, fetchurl
, lib
, meson
, ninja

, gdk-pixbuf
, glib
, gobject-introspection
, python3Packages
, sqlite
}:

let
  channel = "0.3";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gom-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gom/${channel}/${name}.tar.xz";
    sha256 = "ac57e34b5fe273ed306efaeabb346712c264e341502913044a782cdf8c1036d8";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gobject-introspection
    python3Packages.python
    python3Packages.pygobject
    sqlite
  ];

  postPatch = ''
    sed -i bindings/python/meson.build \
      -e "s,pygobject_override_dir),'$out/${python3Packages.python.sitePackages}'),"
  '';

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
    description = "GObject to SQLite object mapper library";
    homepage = https://wiki.gnome.org/Projects/Gom;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
