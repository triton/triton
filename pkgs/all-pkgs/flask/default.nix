{ stdenv
, buildPythonPackage
, fetchPyPi

, click
, itsdangerous
, jinja2
, werkzeug
}:

let
  version = "0.11.1";
in
buildPythonPackage {
  name = "Flask-${version}";

  src = fetchPyPi {
    package = "Flask";
    inherit version;
    sha256 = "b4713f2bfb9ebc2966b8a49903ae0d3984781d5c878591cf2f7b484d28756b0e";
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
