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
  version = "3.5.0";
in
buildPythonPackage {
  name = "keystoneauth1-${version}";

  src = fetchPyPi {
    package = "keystoneauth1";
    inherit version;
    sha256 = "0579c112df9ab6764d6e005b7bacbaf2524f7cfcf9a89cc041b2b72d00414268";
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
