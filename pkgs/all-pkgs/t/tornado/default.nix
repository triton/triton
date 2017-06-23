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

  version = "4.5.1";
in
buildPythonPackage rec {
  name = "tornado-${version}";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "db0904a28253cfe53e7dedc765c71596f3c53bb8a866ae50123320ec1a7b73fd";
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
