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
  version = "3.36.1";
in
buildPythonPackage {
  name = "oslo.utils-${version}";

  src = fetchPyPi {
    package = "oslo.utils";
    inherit version;
    sha256 = "baaffb9d1528bdb5677f8c67828c457d5c015249674a33c62e6a0dbddd9f0e58";
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
