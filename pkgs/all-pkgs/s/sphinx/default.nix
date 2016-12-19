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
  version = "1.5.1";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "8e6a77a20b2df950de322fc32f3b508697d9d654fe984e3cc88f446a5b4c17c5";
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
