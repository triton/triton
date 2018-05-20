{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.1.0";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "a767141fecdab1c0b3c8e4c788ac912d7c94a0d6c452d40777ba84f918316379";
  };

  meta = with lib; {
    description = "Handles managing python package versions in scm metadata";
    homepage = https://bitbucket.org/pypa/setuptools_scm/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
