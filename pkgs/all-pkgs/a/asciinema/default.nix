{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.0.2";
in
buildPythonPackage {
  name = "asciinema-${version}";

  src = fetchPyPi {
    package = "asciinema";
    inherit version;
    sha256 = "32f2c1a046564e030708e596f67e0405425d1eca9d5ec83cd917ef8da06bc423";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
