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

  version = "5.1.0";
in
buildPythonPackage rec {
  name = "pillow-${version}";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "cee9bc75bff455d317b6947081df0824a8f118de2786dc3d74a3503fd631f4ef";
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
