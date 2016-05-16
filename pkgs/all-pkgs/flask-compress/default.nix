{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "flask-compress-${version}";
  version = "1.3.0";

  src = fetchPyPi {
    package = "Flask-Compress";
    inherit version;
    sha256 = "e6c52f1e56b59e8702aed6eb73c6fb0bffe942e5ca188f10e54a33ec11bc5ed4";
  };

  buildInputs = [
    pythonPackages.flask
    pythonPackages.itsdangerous
    pythonPackages.jinja2
    pythonPackages.werkzeug
  ];

  meta = with stdenv.lib; {
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
