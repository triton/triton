{ stdenv
, buildPythonPackage
, fetchPyPi

, markupsafe
}:

let
  version = "2.8";
in
buildPythonPackage rec {
  name = "Jinja2-${version}";

  src = fetchPyPi {
    package = "Jinja2";
    inherit version;
    sha256 = "bc1ff2ff88dbfacefde4ddde471d1417d3b304e8df103a7a9437d47269201bf4";
  };

  propagatedBuildInputs = [
    markupsafe
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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
