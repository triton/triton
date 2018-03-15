{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.28";
in
buildPythonPackage {
  name = "cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "518f7e22da54109661e483a91a63045203caf9fd78da4a69185a7622f759965f";
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
