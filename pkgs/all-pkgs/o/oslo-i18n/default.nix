{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, babel
, pbr
, six
}:

let
  version = "3.18.0";
in
buildPythonPackage {
  name = "oslo.i18n-${version}";

  src = fetchPyPi {
    package = "oslo.i18n";
    inherit version;
    sha256 = "3624459ae0635188645c7f6b61ae0ac8032df3c44e9076d8bdcf215468e486a7";
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
