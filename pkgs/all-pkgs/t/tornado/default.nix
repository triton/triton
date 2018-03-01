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

  version = "4.5.3";
in
buildPythonPackage rec {
  name = "tornado-${version}";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "6d14e47eab0e15799cf3cdcc86b0b98279da68522caace2bd7ce644287685f0a";
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
