{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, python-novaclient
}:

let
  version = "0.3.1";
in
buildPythonPackage {
  name = "rax_scheduled_images_python_novaclient_ext-${version}";

  src = fetchPyPi {
    package = "rax_scheduled_images_python_novaclient_ext";
    inherit version;
    sha256 = "f170cf97b20bdc8a1784cc0b85b70df5eb9b88c3230dab8e68e1863bf3937cdb";
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
