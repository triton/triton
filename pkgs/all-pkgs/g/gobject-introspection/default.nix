{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, lib

, bzip2
, glib
, libffi
, python2

, cairo
}:

let
  inherit (lib)
    boolWt
    optionals
    optionalString;

  channel = "1.56";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "gobject-introspection-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gobject-introspection/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5b2875ccff99ff7baab63a34b67f8c920def240e178ff50add809e267d9ea24b";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    bzip2
    glib
    libffi
    python2
  ] ++ optionals doCheck [
    cairo
  ];

  setupHook = ./setup-hook.sh;

  patches = [
    (fetchTritonPatch {
      rev = "d3fc5e59bd2b4b465c2652aae5e7428b24eb5669";
      file = "gobject-introspection/gobject-introspection-1.x-absolute_shlib_path.patch";
      sha256 = "72be007720645946a4db10e4d845a78ef0d74867db915f414c1ec485f8a2494e";
    })
  ];

  postPatch = /* patchShebangs does not catch @PYTHON@ */ ''
    sed -i tools/g-ir-tool-template.in \
      -e 's|#!/usr/bin/env @PYTHON@|#!${python2.interpreter}|'
  '' +
  optionalString doCheck (''
      patchShebangs ./tests/gi-tester
    '' + /* Fix tests broken by absolute_shlib_path.patch */ ''
      sed -i tests/scanner/{GetType,GtkFrob,Regress,SLetter,Typedefs,Utility}-1.0-expected.gir \
        -e 's|shared-library="|shared-library="/unused/|'
    ''
  );

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doctool"
    "--enable-Bsymbolic"
    "--${boolWt doCheck}-cairo"
  ];

  postInstall = "rm -frv $out/share/gtk-doc";

  doCheck = false;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gobject-introspection/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage = http://live.gnome.org/GObjectIntrospection;
    license = with licenses; [
      lgpl2Plus
      gpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
