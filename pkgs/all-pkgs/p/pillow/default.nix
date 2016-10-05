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

  version = "3.4.1";
in
buildPythonPackage rec {
  name = "pillow-${version}";

  src = fetchPyPi {
    package = "Pillow";
    inherit version;
    sha256 = "590ecade57d9d373b9e73816b811b269693fbd231374b9f52d1bdee1c17d9b40";
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
