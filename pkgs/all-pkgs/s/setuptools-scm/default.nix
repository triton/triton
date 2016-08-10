{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  version = "1.11.1";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "8c45f738a23410c5276b0ed9294af607f491e4260589f1eb90df8312e23819bf";
  };

  meta = with stdenv.lib; {
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
