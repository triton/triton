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
  version = "1.4.8";
in
buildPythonPackage {
  name = "Sphinx-${version}";

  src = fetchPyPi {
    package = "Sphinx";
    inherit version;
    sha256 = "41af978f653ef862eb4bb3776dabd8ff13afed17e431907310fe990a3947707f";
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
