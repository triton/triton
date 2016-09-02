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
  version = "3.0.2";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "64d8937626dd2a4bc15ef0edd307d26636a72a3f3f9664c424d78e40efb1e339";
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
