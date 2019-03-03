{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, babel
, pbr
, six
}:

let
  version = "3.23.1";
in
buildPythonPackage {
  name = "oslo.i18n-${version}";

  src = fetchPyPi {
    package = "oslo.i18n";
    inherit version;
    sha256 = "2669908357e1e49a754dc0c279512246341ae889176c568b89fd9233e65a6ae1";
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
