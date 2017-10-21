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
  version = "3.2.0";
in
buildPythonPackage {
  name = "keystoneauth1-${version}";

  src = fetchPyPi {
    package = "keystoneauth1";
    inherit version;
    sha256 = "768036ee66372df2ad56716b8be4965cef9a59a01647992919516defb282e365";
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
