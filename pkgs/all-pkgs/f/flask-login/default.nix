{ stdenv
, buildPythonPackage
, fetchPyPi

, flask
}:

let
  version = "0.4.0";
in
buildPythonPackage rec {
  name = "flask-login-${version}";

  src = fetchPyPi {
    package = "Flask-Login";
    inherit version;
    sha256 = "d25e356b14a59f52da0ab30c31c2ad285fa23a840f0f6971df7ed247c77082a7";
  };

  buildInputs = [
    flask
  ];

  # No make check target
  doCheck = false;

  meta = with stdenv.lib; {
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
