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
  version = "3.7.0";
in
buildPythonPackage {
  name = "keystoneauth1-${version}";

  src = fetchPyPi {
    package = "keystoneauth1";
    inherit version;
    sha256 = "50ae1e3247f02d71a92b23dc5d19dac553a8c76bbdc9371c074d68d037ff84a1";
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
