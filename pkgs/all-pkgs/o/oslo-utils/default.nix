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
  version = "3.34.0";
in
buildPythonPackage {
  name = "oslo.utils-${version}";

  src = fetchPyPi {
    package = "oslo.utils";
    inherit version;
    sha256 = "9446aaf40cc4633c9c92f31e33b3e9de0c67dcdaa402bd4e414940f6539fc59f";
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
