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
  version = "4.4.2";

  src = fetchPyPi {
    package = "tornado";
    inherit version;
    sha256 = "2898f992f898cd41eeb8d53b6df75495f2f423b6672890aadaf196ea1448edcc";
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
