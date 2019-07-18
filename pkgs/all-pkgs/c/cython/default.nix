{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.29.12";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "20da832a5e9a8e93d1e1eb64650258956723940968eb585506531719b55b804f";
  };

  meta = with lib; {
    description = "A static compiler for Python & Cython programming languages";
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
