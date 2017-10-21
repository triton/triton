{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, ip-associations-python-novaclient-ext
, os-diskconfig-python-novaclient-ext
, os-networksv2-python-novaclient-ext
, os-virtual-interfacesv2-python-novaclient-ext
, python-novaclient
, rackspace-auth-openstack
, rax-default-network-flags-python-novaclient-ext
, rax-scheduled-images-python-novaclient-ext
}:

let
  version = "2.1";
in
buildPythonPackage {
  name = "rackspace-novaclient-${version}";

  src = fetchPyPi {
    package = "rackspace-novaclient";
    inherit version;
    sha256 = "22fc44f623bae0feb32986ec4630abee904e4c96fba5849386a87e88c450eae7";
  };

  propagatedBuildInputs = [
    ip-associations-python-novaclient-ext
    os-diskconfig-python-novaclient-ext
    os-networksv2-python-novaclient-ext
    os-virtual-interfacesv2-python-novaclient-ext
    python-novaclient
    rackspace-auth-openstack
    rax-default-network-flags-python-novaclient-ext
    rax-scheduled-images-python-novaclient-ext
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
