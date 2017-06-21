{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, tempora
}:

let
  version = "1.8";
in
buildPythonPackage rec {
  name = "portend-${version}";

  src = fetchPyPi {
    package = "portend";
    inherit version;
    sha256 = "7de919b82c4ac60d4768fe80a2557290661aa665b7c427de6249d8cb2fde5561";
  };

  propagatedBuildInputs = [
    setuptools-scm
    tempora
  ];

  meta = with lib; {
    description = "TCP port monitoring utilities";
    homepage = https://github.com/jaraco/portend;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
