{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.3.0";
in
buildPythonPackage {
  name = "asciinema-${version}";

  src = fetchPyPi {
    package = "asciinema";
    inherit version;
    sha256 = "acc1a07306c7af02cd9bc97c32e4748dbfa57ff11beb17fea64eaee67eaa2db3";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
