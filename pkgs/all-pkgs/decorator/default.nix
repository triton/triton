{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "4.0.9";
in
buildPythonPackage {
  name = "decorator-${version}";

  src = fetchPyPi {
    package = "decorator";
    inherit version;
    sha256 = "90022e83316363788a55352fe39cfbed357aa3a71d90e5f2803a35471de4bba8";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
