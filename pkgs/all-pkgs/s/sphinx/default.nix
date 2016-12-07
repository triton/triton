{ stdenv
, buildPythonPackage
, fetchPyPi

, alabaster
, babel
, docutils
, imagesize
, jinja2
, pygments
, requests
, six
, snowballstemmer
}:

let
  version = "1.5";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "1c52ac7696c4d37bb7bc59c58df81756928816e88624ba625f12082a9e9eb8f9";
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
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
