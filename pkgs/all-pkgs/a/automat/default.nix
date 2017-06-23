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
  version = "0.6.0";
in
buildPythonPackage {
  name = "Automat-${version}";

  src = fetchPyPi {
    package = "Automat";
    inherit version;
    sha256 = "3c1fd04ecf08ac87b4dd3feae409542e9bf7827257097b2b6ed5692f69d6f6a8";
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
