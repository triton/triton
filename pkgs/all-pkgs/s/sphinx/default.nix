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
  version = "1.6.6";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "c39a6fa41bd3ec6fc10064329a664ed3a3ca2e27640a823dc520c682e4433cdb";
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
