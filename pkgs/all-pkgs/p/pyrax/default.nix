{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, keyring
, mock
, python-novaclient
, rackspace-novaclient
}:

let
  version = "1.9.8";
in
buildPythonPackage {
  name = "pyrax-${version}";

  src = fetchPyPi {
    package = "pyrax";
    inherit version;
    sha256 = "e9db943447fdf2690046d7f98466fc4743497b74578efe6e400a6edbfd9728f5";
  };
  
  propagatedBuildInputs = [
    keyring
    mock
    python-novaclient
    rackspace-novaclient
  ];

  postPatch = ''
    grep -q 'python-novaclient==2.27.0' setup.py
    sed -i 's,python-novaclient==2.27.0,python-novaclient,g' setup.py
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
