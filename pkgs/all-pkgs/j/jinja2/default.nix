{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, markupsafe
}:

let
  version = "2.10";
in
buildPythonPackage rec {
  name = "Jinja2-${version}";

  src = fetchPyPi {
    package = "Jinja2";
    inherit version;
    sha256 = "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4";
  };

  propagatedBuildInputs = [
    markupsafe
  ];

  doCheck = true;

  meta = with lib; {
    description = "Jinja2 is a template engine written in pure Python";
    homepage = http://jinja.pocoo.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
