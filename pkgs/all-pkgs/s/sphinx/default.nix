{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, alabaster
, babel
, docutils
, imagesize
, jinja2
, pygments
, requests
, six
, snowballstemmer
, sphinxcontrib-websupport
}:

let
  version = "1.6.4";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "f101efd87fbffed8d8aca6ef307fec57693334f39d32efcbc2fc96ed129f4a3e";
  };

  propagatedBuildInputs = [
    alabaster
    babel
    docutils
    imagesize
    jinja2
    pygments
    requests
    six
    snowballstemmer
    sphinxcontrib-websupport
  ];

  meta = with lib; {
    description = "Python2 documentation generator";
    homepage = http://sphinx.pocoo.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
