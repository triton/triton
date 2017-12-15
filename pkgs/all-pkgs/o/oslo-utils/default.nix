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
  version = "3.33.0";
in
buildPythonPackage {
  name = "oslo.utils-${version}";

  src = fetchPyPi {
    package = "oslo.utils";
    inherit version;
    sha256 = "2b1b08626852a580078bdda2be8e5262a73d27568b75d92bc203341d364577be";
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
