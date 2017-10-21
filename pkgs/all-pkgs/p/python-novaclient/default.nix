{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, babel
, keystoneauth1
, oslo-serialization
, oslo-utils
, pbr
, prettytable
, requests
, simplejson
}:

let
  version = "6.0.2";
in
buildPythonPackage {
  name = "python-novaclient-${version}";

  src = fetchPyPi {
    package = "python-novaclient";
    inherit version;
    sha256 = "9bc43ee491780ce073666aa8ca0a4cea665a8fbf008780745de3dbbe32ccf37d";
  };

  propagatedBuildInputs = [
    babel
    keystoneauth1
    oslo-serialization
    oslo-utils
    pbr
    prettytable
    requests
    simplejson
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
