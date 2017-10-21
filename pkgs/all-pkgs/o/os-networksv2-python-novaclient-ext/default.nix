{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "0.26";
in
buildPythonPackage {
  name = "os_networksv2_python_novaclient_ext-${version}";

  src = fetchPyPi {
    package = "os_networksv2_python_novaclient_ext";
    inherit version;
    sha256 = "613a75216d98d3ce6bb413f717323e622386c24fc9cc66148507539e7dc5bf19";
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
