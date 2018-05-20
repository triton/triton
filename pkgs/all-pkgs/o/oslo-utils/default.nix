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
  version = "3.36.2";
in
buildPythonPackage {
  name = "oslo.utils-${version}";

  src = fetchPyPi {
    package = "oslo.utils";
    inherit version;
    sha256 = "9900be2bc8bf14c187731393dea672ea9579312d6f31b862e527999fde63f2c6";
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
