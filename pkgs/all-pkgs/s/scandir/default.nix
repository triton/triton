{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, scandir
, six
}:

let
  inherit (lib)
    optionals;

  version = "1.5";
in
buildPythonPackage {
  name = "scandir-${version}";

  src = fetchPyPi {
    package = "scandir";
    inherit version;
    sha256 = "c2612d1a487d80fb4701b4a91ca1b8f8a695b1ae820570815e85e8c8b23f1283";
  };

  meta = with lib; {
    description = "A better directory iterator and faster os.walk()";
    homepage = https://github.com/benhoyt/scandir;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
