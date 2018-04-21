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
  version = "1.7.2";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "5a1c9a0fec678c24b9a2f5afba240c04668edb7f45c67ce2ed008996b3f21ae2";
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
