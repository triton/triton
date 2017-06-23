{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "3.4.0.3";
in
buildPythonPackage rec {
  name = "singledispatch-${version}";

  src = fetchPyPi {
    package = "singledispatch";
    inherit version;
    sha256 = "5b06af87df13818d14f08a028e42f566640aef80805c3b50c5056b086e3c2b9c";
  };

  buildInputs = [
    six
  ];

  meta = with lib; {
    description = "Backport of functools.singledispatch from Python 3.4";
    homepage = https://pypi.python.org/pypi/singledispatch;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
