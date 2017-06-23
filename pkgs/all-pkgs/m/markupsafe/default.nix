{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0";
in
buildPythonPackage rec {
  name = "markupsafe-${version}";

  src = fetchPyPi {
    package = "MarkupSafe";
    inherit version;
    sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665";
  };

  meta = with lib; {
    description = "Implements a XML/HTML/XHTML Markup safe string for Python";
    homepage = http://github.com/mitsuhiko/markupsafe;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
