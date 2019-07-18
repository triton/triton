{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.4.0";
in
buildPythonPackage {
  name = "decorator-${version}";

  src = fetchPyPi {
    package = "decorator";
    inherit version;
    sha256 = "86156361c50488b84a3f148056ea716ca587df2f0de1d34750d35c21312725de";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
