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

  version = "4.1.1";
in
buildPythonPackage rec {
  name = "pillow-${version}";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "00b6a5f28d00f720235a937ebc2f50f4292a5c7e2d6ab9a8b26153b625c4f431";
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
