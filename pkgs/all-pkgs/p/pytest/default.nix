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
  version = "3.0.1";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "e82bc0596ee96b2287c08705cfcb6898db1fe4b5c87db3b6823f1fdd77fb3ff1";
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
