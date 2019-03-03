{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, iso8601
, pbr
, requests
, six
, stevedore
}:

let
  version = "3.13.0";
in
buildPythonPackage {
  name = "keystoneauth1-${version}";

  src = fetchPyPi {
    package = "keystoneauth1";
    inherit version;
    sha256 = "eea3bf0d6de0f1e965f7162f82ea1a8394af3cb7b33e67c6227189b48344f207";
  };

  propagatedBuildInputs = [
    iso8601
    pbr
    requests
    six
    stevedore
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
