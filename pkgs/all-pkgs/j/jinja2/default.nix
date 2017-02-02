{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, markupsafe
}:

let
  version = "2.9.5";
in
buildPythonPackage rec {
  name = "Jinja2-${version}";

  src = fetchPyPi {
    package = "Jinja2";
    inherit version;
    sha256 = "702a24d992f856fa8d5a7a36db6128198d0c21e1da34448ca236c42e92384825";
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
