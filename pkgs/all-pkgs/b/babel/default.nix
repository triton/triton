{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytz
}:

let
  version = "2.5.3";
in
buildPythonPackage {
  name = "Babel-${version}";

  src = fetchPyPi {
    package = "Babel";
    inherit version;
    sha256 = "8ce4cb6fdd4393edd323227cba3a077bceb2a6ce5201c902c65e730046f41f14";
  };

  propagatedBuildInputs = [
    pytz
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
