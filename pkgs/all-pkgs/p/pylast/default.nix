{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "2.2.0";
in
buildPythonPackage rec {
  name = "pylast-${version}";

  src = fetchPyPi {
    package = "pylast";
    inherit version;
    sha256 = "a21a10e559cbb80db5eb72e20a22740496a292977ed3568c937560b8d6885ab4";
  };

  propagatedBuildInputs = [
    six
  ];

  meta = with lib; {
    description = "A Python interface to Last.fm and Libre.fm";
    homepage = https://github.com/pylast/pylast;
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
