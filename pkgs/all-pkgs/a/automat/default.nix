{ stdenv
, buildPythonPackage
, fetchPyPi

, attrs
, docutils
, m2r
, setuptools-scm
, six
}:

let
  version = "0.5.0";
in
buildPythonPackage {
  name = "Automat-${version}";

  src = fetchPyPi {
    package = "Automat";
    inherit version;
    sha256 = "4889ec6763377432ec4db265ad552bbe956768ea3fff39014855308ba79dd7c2";
  };

  buildInputs = [
    docutils
    m2r
    setuptools-scm
  ];

  propagatedBuildInputs = [
    attrs
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
