{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "1.3";
in
buildPythonPackage {
  name = "rackspace-auth-openstack-${version}";

  src = fetchPyPi {
    package = "rackspace-auth-openstack";
    inherit version;
    sha256 = "c4c069eeb1924ea492c50144d8a4f5f1eb0ece945e0c0d60157cabcadff651cd";
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
