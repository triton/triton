{ stdenv
, buildPythonPackage
, fetchPyPi

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
  inherit (stdenv.lib)
    optionals;
in
buildPythonPackage rec {
  name = "flask-restful-${version}";
  version = "0.3.5";

  src = fetchPyPi {
    package = "Flask-RESTful";
    inherit version;
    sha256 = "cce4aeff959b571136b5af098bebe7d3deeca7eb1411c4e722ff2c5356ab4c42";
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

  meta = with stdenv.lib; {
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
