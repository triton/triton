{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "2.1.0";
in
buildPythonPackage rec {
  name = "pylast-${version}";

  src = fetchPyPi {
    package = "pylast";
    inherit version;
    sha256 = "b9b51dc40a7d3ac3eee17ab5b462b8efb7f2c2ff195261ea846ae4e1168e1c5b";
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
