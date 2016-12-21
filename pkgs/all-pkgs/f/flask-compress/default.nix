{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, flask
, itsdangerous
, jinja2
, werkzeug
}:

let
  version = "1.3.2";
in
buildPythonPackage rec {
  name = "flask-compress-${version}";

  src = fetchPyPi {
    package = "Flask-Compress";
    inherit version;
    sha256 = "4fbb53e7f6ce8b1458a2c3d7a528564912f2641ab2f9f43819fc96ed7f770734";
  };

  buildInputs = [
    flask
    itsdangerous
    jinja2
    werkzeug
  ];

  meta = with lib; {
    description = "Compress responses in your Flask app with gzip";
    homepage = https://github.com/wichitacode/flask-compress;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
