{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "0.2";
in
buildPythonPackage {
  name = "ip_associations_python_novaclient_ext-${version}";

  src = fetchPyPi {
    package = "ip_associations_python_novaclient_ext";
    inherit version;
    sha256 = "e4576c3ee149bcca7e034507ad9c698cb07dd9fa10f90056756aea0fa59bae37";
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
