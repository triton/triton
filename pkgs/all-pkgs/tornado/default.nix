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
  version = "4.3";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "c9c2d32593d16eedf2cec1b6a41893626a2649b40b21ca9c4cac4243bde2efbf";
  };

  buildInputs = [
    pythonPackages.six
  ] ++ optionals (pythonOlder "3.2") [
    pythonPackages.backports-ssl-match-hostname
  ] ++ optionals (pythonOlder "3.4") [
    pythonPackages.singledispatch
    pythonPackages.certifi
  ] ++ optionals (pythonOlder "3.5") [
    pythonPackages.backports-abc
  ];

  doCheck = true;

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
