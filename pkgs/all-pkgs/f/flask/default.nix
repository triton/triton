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
  version = "1.1.1";
in
buildPythonPackage {
  name = "Flask-${version}";

  src = fetchPyPi {
    package = "Flask";
    inherit version;
    sha256 = "13f9f196f330c7c2c5d7a5cf91af894110ca0215ac051b5844701f2bfd934d52";
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
