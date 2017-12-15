{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, flask
}:

let
  version = "0.4.1";
in
buildPythonPackage rec {
  name = "flask-login-${version}";

  src = fetchPyPi {
    package = "Flask-Login";
    inherit version;
    sha256 = "c815c1ac7b3e35e2081685e389a665f2c74d7e077cb93cecabaea352da4752ec";
  };

  buildInputs = [
    flask
  ];

  # No make check target
  doCheck = false;

  meta = with lib; {
    description = "User session management for Flask";
    homepage = https://github.com/maxcountryman/flask-login;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
