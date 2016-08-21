{ stdenv
, buildPythonPackage
, fetchPyPi

, isPy3k
, py
}:

let
  inherit (stdenv.lib)
    optionalString;
in

buildPythonPackage rec {
  name = "pytest-${version}";
  version = "3.0.0";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "a37795bbc4005400b281b72613cd6a13261ffde615c6d539d94ca915fc507192";
  };

  propagatedBuildInputs = [
    py
  ];

  meta = with stdenv.lib; {
    description = "Simple powerful testing framework for Python";
    homepage = https://pytest.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
