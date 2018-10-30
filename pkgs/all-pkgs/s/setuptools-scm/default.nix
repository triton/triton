{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.1.0";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "1191f2a136b5e86f7ca8ab00a97ef7aef997131f1f6d4971be69a1ef387d8b40";
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
