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
  version = "3.4.0";
in
buildPythonPackage {
  name = "keystoneauth1-${version}";

  src = fetchPyPi {
    package = "keystoneauth1";
    inherit version;
    sha256 = "9f1565eb261677e6d726c1323ce8ed8da3e1b0f70e9cee14f094ebd03fbeb328";
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
