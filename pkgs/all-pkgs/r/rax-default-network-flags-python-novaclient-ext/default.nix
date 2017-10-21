{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "0.4.0";
in
buildPythonPackage {
  name = "rax_default_network_flags_python_novaclient_ext-${version}";

  src = fetchPyPi {
    package = "rax_default_network_flags_python_novaclient_ext";
    inherit version;
    sha256 = "852bf49d90e7a1bc16aa0b25b46a45ba5654069f7321a363c8d94c5496666001";
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
