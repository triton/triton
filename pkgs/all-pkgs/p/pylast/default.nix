{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "1.8.0";
in
buildPythonPackage rec {
  name = "pylast-${version}";

  src = fetchPyPi {
    package = "pylast";
    inherit version;
    sha256 = "85f8dd96aef0ccba5f80379c3d7bc1fabd72f59aebab040daf40a8b72268f9bd";
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
