{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, aniso8601
, flask
, pytz
, six

, blinker
, mock
, nose
, pycrypto
}:

let
  inherit (lib)
    optionals;

  version = "0.3.6";
in
buildPythonPackage rec {
  name = "flask-restful-${version}";

  src = fetchPyPi {
    package = "Flask-RESTful";
    inherit version;
    sha256 = "5795519501347e108c436b693ff9a4d7b373a3ac9069627d64e4001c05dd3407";
  };

  buildInputs = [
    aniso8601
    flask
    pytz
    six
  ] ++ optionals doCheck [
    blinker
    mock
    nose
    pycrypto
  ];

  doCheck = false;

  meta = with lib; {
    description = "Simple framework for creating REST APIs";
    homepage = https://github.com/flask-restful/flask-restful/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
