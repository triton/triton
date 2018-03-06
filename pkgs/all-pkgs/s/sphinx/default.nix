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
  version = "1.7.1";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "da987de5fcca21a4acc7f67a86a363039e67ac3e8827161e61b91deb131c0ee8";
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
