{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "0.1.3";
in
buildPythonPackage {
  name = "os_diskconfig_python_novaclient_ext-${version}";

  src = fetchPyPi {
    package = "os_diskconfig_python_novaclient_ext";
    inherit version;
    sha256 = "e7d19233a7b73c70244d2527d162d8176555698e7c621b41f689be496df15e75";
  };

  propagatedBuildInputs = [
    python-novaclient
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
