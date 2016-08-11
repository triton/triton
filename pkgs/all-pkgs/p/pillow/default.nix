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
  version = "3.3.0";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "031e7c9c885a4f343d1ad366c7fd2340449dc70318acb4a28d6411994f0accd1";
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
