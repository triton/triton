{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.5.0";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "5bdf21a05792903cafe7ae0c9501182ab52497614fa6b1750d9dbae7b60c1a87";
  };

  # Fix missing version
  postPatch = ''
    grep -q 'version=' setup.py
    sed -i "/name=\"/a\    version='${version}'," setup.py
  '';

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
