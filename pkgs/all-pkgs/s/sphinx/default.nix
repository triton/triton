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
  version = "1.6.3";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "af8bdb8c714552b77d01d4536e3d6d2879d6cb9d25423d29163d5788e27046e6";
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
