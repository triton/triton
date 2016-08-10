{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "markupsafe-${version}";
  version = "0.23";

  src = fetchPyPi {
    package = "MarkupSafe";
    inherit version;
    sha256 = "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3";
  };

  meta = with stdenv.lib; {
    description = "Implements a XML/HTML/XHTML Markup safe string for Python";
    homepage = http://github.com/mitsuhiko/markupsafe;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
