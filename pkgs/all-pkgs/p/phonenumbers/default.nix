{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "8.4.2";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "9f5c5eef95eab7fc637ea43f97ef69051dbb2674655cb89d8abd3db401d3f353";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
