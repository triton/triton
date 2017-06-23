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
  version = "1.4.0";
in
buildPythonPackage rec {
  name = "flask-compress-${version}";

  src = fetchPyPi {
    package = "Flask-Compress";
    inherit version;
    sha256 = "468693f4ddd11ac6a41bca4eb5f94b071b763256d54136f77957cfee635badb3";
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
