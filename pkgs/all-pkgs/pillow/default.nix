{ stdenv
, buildPythonPackage
, fetchPyPi

, freetype
, lcms2
, libjpeg
, libtiff
, libwebp
, openjpeg
, zlib
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "pillow-${version}";
  version = "3.2.0";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "64b0a057210c480aea99406c9391180cd866fc0fd8f0b53367e3af21b195784a";
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

  preBuild = ''
    export CFLAGS="$(echo "$NIX_CFLAGS_COMPILE" | sed 's,-isystem ,-I,g')"
    export LDFLAGS="$(echo "$NIX_LDFLAGS" | sed 's,-rpath [^ ]*,,g')"
  '';

  meta = with stdenv.lib; {
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
