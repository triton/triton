{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, freetype
, lcms2
, libjpeg
, libtiff
, libwebp
, olefile
, openjpeg
, zlib
}:

let
  inherit (lib)
    optionals;

  version = "5.0.0";
in
buildPythonPackage rec {
  name = "pillow-${version}";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "12f29d6c23424f704c66b5b68c02fe0b571504459605cfe36ab8158359b0e1bb";
  };

  buildInputs = [
    freetype
    lcms2
    libjpeg
    libtiff
    libwebp
    openjpeg
    zlib
  ];

  propagatedBuildInputs = [
    olefile
  ];

  preBuild = ''
    export CFLAGS="$(echo "$NIX_CFLAGS_COMPILE" | sed 's,-isystem ,-I,g')"
    export LDFLAGS="$(echo "$NIX_LDFLAGS" | sed 's,-rpath [^ ]*,,g')"
  '';

  meta = with lib; {
    description = "Fork of The Python Imaging Library (PIL)";
    homepage = http://python-pillow.org/;
    license = licenses.free; # PIL license
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
