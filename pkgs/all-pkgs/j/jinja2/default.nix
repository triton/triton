{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, markupsafe
}:

let
  version = "2.9.6";
in
buildPythonPackage rec {
  name = "Jinja2-${version}";

  src = fetchPyPi {
    package = "Jinja2";
    inherit version;
    sha256 = "ddaa01a212cd6d641401cb01b605f4a4d9f37bfc93043d7f760ec70fb99ff9ff";
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
