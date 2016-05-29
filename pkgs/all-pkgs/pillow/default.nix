{ stdenv
, buildPythonPackage
, fetchPyPi

, pkgs
, pythonPackages
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

  propagatedBuildInputs = [
    pkgs.freetype
    #imagequant
    pkgs.lcms2
    pkgs.libjpeg
    pkgs.libtiff
    # TODO: webp support
    #pkgs.libwebp
    pkgs.openjpeg
    pkgs.tcl
    pkgs.tk
    pkgs.zlib
    # TODO: tkinter support
  ] ++ optionals doCheck [
    pythonPackages.nose
  ];

  preConfigure = ''
    sed -i "setup.py" \
      -e 's|^FREETYPE_ROOT =.*$|FREETYPE_ROOT = _lib_include("${pkgs.freetype}")|g ;
          s|^JPEG_ROOT =.*$|JPEG_ROOT = _lib_include("${pkgs.libjpeg}")|g ;
          s|^ZLIB_ROOT =.*$|ZLIB_ROOT = _lib_include("${pkgs.zlib}")|g ;
          s|^LCMS_ROOT =.*$|LCMS_ROOT = _lib_include("${pkgs.lcms2}")|g ;
          s|^TIFF_ROOT =.*$|TIFF_ROOT = _lib_include("${pkgs.libtiff}")|g ;
          s|^JPEG2K_ROOT =.*$|JPEG2K_ROOT = _lib_include("${pkgs.openjpeg}")|g ;
          s|^TCL_ROOT=.*$|TCL_ROOT = _lib_include("${pkgs.tcl}")|g ;'
  '';

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Fork of The Python Imaging Library (PIL)";
    homepage = http://python-pillow.org/;
    license = licenses.free; # PIL license
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
