{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, tempora
}:

let
  version = "2.3";
in
buildPythonPackage rec {
  name = "portend-${version}";

  src = fetchPyPi {
    package = "portend";
    inherit version;
    sha256 = "b7ce7d35ea262415297cbfea86226513e77b9ee5f631d3baa11992d663963719";
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
