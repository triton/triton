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
  version = "1.5.2";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "049c48393909e4704a6ed4de76fd39c8622e165414660bfb767e981e7931c722";
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
