{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.12.3";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "de5d266953875e9647e37ef7bfe6ef1a46ff8ddfe61b5b3652edf7ea717ee2b2";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
