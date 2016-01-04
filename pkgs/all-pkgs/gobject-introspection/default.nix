{ stdenv
, bison
, fetchurl
, flex

, glib
, libffi
, python
# Tests
, cairo
}:

with {
  inherit (stdenv.lib)
    optionals
    optionalString
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "gobject-introspection-${versionMajor}.${versionMinor}";
  versionMajor = "1.46";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gobject-introspection/${versionMajor}/${name}.tar.xz";
    sha256 = "0cs27r18fga44ypp8icy62fwx6nh70r1bvhi4lzfn4w85cybsn36";
  };

  setupHook = ./setup-hook.sh;

  patches = [
    ./absolute_shlib_path.patch
  ];

  postPatch = ''
    # patchShebangs does not catch @PYTHON@
    sed -e 's|#!/usr/bin/env @PYTHON@|#!${python.interpreter}|' \
        -i tools/g-ir-tool-template.in
  '' + optionalString doCheck ''
    patchShebangs tests/gi-tester

    # Fix tests broken by absolute_shlib_path.patch
    sed -e 's|shared-library="|shared-library="/unused/|' -i \
      tests/scanner/GtkFrob-1.0-expected.gir \
      tests/scanner/Utility-1.0-expected.gir \
      tests/scanner/Typedefs-1.0-expected.gir \
      tests/scanner/GetType-1.0-expected.gir \
      tests/scanner/SLetter-1.0-expected.gir \
      tests/scanner/Regress-1.0-expected.gir
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doctool"
    "--enable-Bsymbolic"
    (wtFlag "cairo" doCheck null)
  ];

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    glib
    libffi
    python
  ] ++ optionals doCheck [
    cairo
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  doCheck = true;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage = http://live.gnome.org/GObjectIntrospection;
    license = with licenses; [
      lgpl2Plus
      gpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
