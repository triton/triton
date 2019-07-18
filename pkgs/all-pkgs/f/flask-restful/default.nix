{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, aniso8601
, flask
, pytz
, six
}:

let
  version = "0.3.7";
in
buildPythonPackage rec {
  name = "flask-restful-${version}";

  src = fetchPyPi {
    package = "Flask-RESTful";
    inherit version;
    sha256 = "f8240ec12349afe8df1db168ea7c336c4e5b0271a36982bff7394f93275f2ca9";
  };

  buildInputs = [
    aniso8601
    flask
    pytz
    six
  ];

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
