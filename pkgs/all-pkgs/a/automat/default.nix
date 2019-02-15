{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, attrs
, docutils
, m2r
, setuptools-scm
, six
}:

let
  version = "0.7.0";
in
buildPythonPackage {
  name = "Automat-${version}";

  src = fetchPyPi {
    package = "Automat";
    inherit version;
    sha256 = "cbd78b83fa2d81fe2a4d23d258e1661dd7493c9a50ee2f1a5b2cac61c1793b0e";
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

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
