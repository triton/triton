{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pythonOlder
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "tornado-${version}";
  version = "4.4.3";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "f267acc96d5cf3df0fd8a7bfb5a91c2eb4ec81d5962d1a7386ceb34c655634a8";
  };

  propagatedBuildInputs = [
    pythonPackages.six
  ] ++ optionals (pythonOlder "3.2") [
    pythonPackages.backports-ssl-match-hostname
  ] ++ optionals (pythonOlder "3.4") [
    pythonPackages.singledispatch
    pythonPackages.certifi
  ] ++ optionals (pythonOlder "3.5") [
    pythonPackages.backports-abc
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
