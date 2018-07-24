{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.0.2";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "113cea38b2edba8538b7e608b58cbd7e09bb71b16d968a9b97e36b4805e06d59";
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
