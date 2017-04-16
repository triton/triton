{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "8.4.1";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "144fc7d33729ef887d53684ee8529e0e0c13893432cda56cc5cae52303645e0f";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
