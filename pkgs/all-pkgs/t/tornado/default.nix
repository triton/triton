{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonOlder

, backports-abc
, backports-ssl-match-hostname
, certifi
, singledispatch
, six
}:

let
  inherit (lib)
    optionals;

  version = "4.5.2";
in
buildPythonPackage rec {
  name = "tornado-${version}";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "1fb8e494cd46c674d86fac5885a3ff87b0e283937a47d74eb3c02a48c9e89ad0";
  };

  propagatedBuildInputs = [
    six
  ] ++ optionals (pythonOlder "3.2") [
    backports-ssl-match-hostname
  ] ++ optionals (pythonOlder "3.4") [
    singledispatch
    certifi
  ] ++ optionals (pythonOlder "3.5") [
    backports-abc
  ];

  doCheck = false;

  meta = with lib; {
    description = "Web framework and asynchronous networking library";
    homepage = http://www.tornadoweb.org/;
    license = licenses.asl20; # apache
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
