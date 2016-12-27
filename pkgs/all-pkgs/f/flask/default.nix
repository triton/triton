{ stdenv
, buildPythonPackage
, fetchPyPi

, click
, itsdangerous
, jinja2
, werkzeug
}:

let
  version = "0.12";
in
buildPythonPackage {
  name = "Flask-${version}";

  src = fetchPyPi {
    package = "Flask";
    inherit version;
    sha256 = "93e803cdbe326a61ebd5c5d353959397c85f829bec610d59cb635c9f97d7ca8b";
  };

  propagatedBuildInputs = [
    click
    itsdangerous
    jinja2
    werkzeug
  ];

  meta = with stdenv.lib; {
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
