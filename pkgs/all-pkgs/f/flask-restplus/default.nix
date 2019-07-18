{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, aniso8601
, flask
, jsonschema
, pytz
, six
}:

let
  version = "0.12.1";
in
buildPythonPackage rec {
  name = "flask-restplus-${version}";

  src = fetchPyPi {
    package = "flask-restplus";
    inherit version;
    sha256 = "3fad697e1d91dfc13c078abcb86003f438a751c5a4ff41b84c9050199d2eab62";
  };

  propagatedBuildInputs = [
    aniso8601
    flask
    jsonschema
    pytz
    six
  ];

  meta = with lib; {
    description = "Framework for fast, easy and documented API development";
    homepage = https://github.com/noirbizarre/flask-restplus;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
