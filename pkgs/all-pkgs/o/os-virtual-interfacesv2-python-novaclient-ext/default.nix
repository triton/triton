{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "0.20";
in
buildPythonPackage {
  name = "os_virtual_interfacesv2_python_novaclient_ext-${version}";

  src = fetchPyPi {
    package = "os_virtual_interfacesv2_python_novaclient_ext";
    inherit version;
    sha256 = "6d39ff4174496a0f795d11f20240805a16bbf452091cf8eb9bd1d5ae2fca449d";
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
