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

  version = "5.0.2";
in
buildPythonPackage rec {
  name = "tornado-${version}";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "1b83d5c10550f2653380b4c77331d6f8850f287c4f67d7ce1e1c639d9222fbc7";
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
