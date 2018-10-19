{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.29";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "94916d1ede67682638d3cc0feb10648ff14dc51fb7a7f147f4fedce78eaaea97";
  };

  meta = with lib; {
    description = "An optimising static compiler for the Python and Cython programming languages";
    homepage = http://cython.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
