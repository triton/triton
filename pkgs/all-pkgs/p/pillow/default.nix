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

  version = "4.2.1";
in
buildPythonPackage rec {
  name = "pillow-${version}";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "c724f65870e545316f9e82e4c6d608ab5aa9dd82d5185e5b2e72119378740073";
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
