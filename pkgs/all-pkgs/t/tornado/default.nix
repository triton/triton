{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonOlder
, pythonPackages
}:

let
  inherit (stdenv.lib)
    optionals;
in

buildPythonPackage rec {
  name = "tornado-${version}";
  version = "4.4.1";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "371d0cf3d56c47accc66116a77ad558d76eebaa8458a6b677af71ca606522146";
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

  meta = with stdenv.lib; {
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
