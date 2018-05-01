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
  version = "1.0.1";
in
buildPythonPackage {
  name = "Flask-${version}";

  src = fetchPyPi {
    package = "Flask";
    inherit version;
    sha256 = "cfc15b45622f9cfee6b5803723070fd0f489b3bd662179195e702cb95fd924c8";
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
