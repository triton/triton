{ stdenv
, buildPythonPackage
, fetchPyPi

, alabaster
, babel
, docutils
, imagesize
, jinja2
, pygments
, six
, snowballstemmer
}:

let
  version = "1.4.6";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "9e43430aa9b491ecd86302a1320edb8977da624f63422d494257eab2541a79d3";
  };

  propagatedBuildInputs = [
    alabaster
    babel
    docutils
    imagesize
    jinja2
    pygments
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
