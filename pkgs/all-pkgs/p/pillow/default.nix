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

  version = "4.1.0";
in
buildPythonPackage rec {
  name = "pillow-${version}";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "a0fd487fed4a35717401b7566e51a1520b34e7c0f7f2a315a6509f82bc86299f";
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
