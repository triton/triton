{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, click
, itsdangerous
, jinja2
, werkzeug
}:

let
  version = "0.12.2";
in
buildPythonPackage {
  name = "Flask-${version}";

  src = fetchPyPi {
    package = "Flask";
    inherit version;
    sha256 = "49f44461237b69ecd901cc7ce66feea0319b9158743dd27a2899962ab214dac1";
  };

  propagatedBuildInputs = [
    click
    itsdangerous
    jinja2
    werkzeug
  ];

  meta = with lib; {
    description = "Micro webdevelopment framework for Python";
    homepage = http://flask.pocoo.org/;
    licenses = license.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
