{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "flask-login-${version}";
  version = "0.3.2";

  src = fetchPyPi {
    package = "Flask-Login";
    inherit version;
    sha256 = "e72eff5c35e5a31db1aeca1db5d2501be702674ea88e8f223b5d2b11644beee6";
  };

  buildInputs = [
    pythonPackages.flask
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
