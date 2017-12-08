{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, babel
, pbr
, six
}:

let
  version = "3.19.0";
in
buildPythonPackage {
  name = "oslo.i18n-${version}";

  src = fetchPyPi {
    package = "oslo.i18n";
    inherit version;
    sha256 = "9711548b5a7c18a2b41f5d91f2f907f93b396b8a6c9b5b2aaf2b63560a768ba2";
  };

  propagatedBuildInputs = [
    babel
    pbr
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
