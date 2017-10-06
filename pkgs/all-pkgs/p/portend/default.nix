{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, tempora
}:

let
  version = "2.2";
in
buildPythonPackage rec {
  name = "portend-${version}";

  src = fetchPyPi {
    package = "portend";
    inherit version;
    sha256 = "bc48d3d99e1eaf2e9406c729f8848bfdaf87876cd3560dc3ec6c16714f529586";
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
