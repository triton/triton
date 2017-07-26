{ stdenv
, fetchurl
, gettext
, lib

, glib
, gobject-introspection
}:

let
  inherit (lib)
    boolEn;

  versionMajor = "1.2";
  versionMinor = "8";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "json-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${versionMajor}/${name}.tar.xz";
    sha256 = "fd55a9037d39e7a10f0db64309f5f0265fa32ec962bf85066087b83a2807f40a";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  configureFlags= [
    "--enable-Bsymbolic"
    "--disable-debug"
    "--disable-maintainer-mode"
    "--disable-installed-tests"
    "--disable-always-build-tests"
    "--disable-gcov"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-man"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--enable-nls"
    "--enable-rpath"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/json-glib/${versionMajor}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "(de)serialization support for JSON";
    homepage = http://live.gnome.org/JsonGlib;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
