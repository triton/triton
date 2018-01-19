{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, debtcollector
, funcsigs
, iso8601
, monotonic
, netaddr
, netifaces
, oslo-i18n
, pbr
, pyparsing
, pytz
}:

let
  version = "3.35.0";
in
buildPythonPackage {
  name = "oslo.utils-${version}";

  src = fetchPyPi {
    package = "oslo.utils";
    inherit version;
    sha256 = "7d7900ceae96c054cf190f6a157dcdb7e168a6cf26660de7302540af95f729aa";
  };

  propagatedBuildInputs = [
    debtcollector
    funcsigs
    iso8601
    monotonic
    netaddr
    netifaces
    oslo-i18n
    pbr
    pyparsing
    pytz
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
