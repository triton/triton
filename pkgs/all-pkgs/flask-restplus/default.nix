{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "flask-restplus-${version}";
  version = "0.9.2";

  src = fetchPyPi {
    package = "flask-restplus";
    inherit version;
    sha256 = "c4313097a673ef2cffabceb44b6fdd03132ee5e7ab34d0289c37af12a3d11186";
  };

  propagatedBuildInputs = [
    pythonPackages.aniso8601
    pythonPackages.flask
    pythonPackages.jsonschema
    pythonPackages.pytz
    pythonPackages.six
  ] ++ optionals doCheck [
    pythonPackages.blinker
    pythonPackages.mock
    pythonPackages.nose
    #pythonPackages.rednose
    pythonPackages.tzlocal
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Framework for fast, easy and documented API development";
    homepage = https://github.com/noirbizarre/flask-restplus;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
