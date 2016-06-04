{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.8.2";
in
buildPythonPackage {
  name = "simplejson-${version}";

  src = fetchPyPi {
    package = "simplejson";
    inherit version;
    sha256 = "d58439c548433adcda98e695be53e526ba940a4b9c44fb9a05d92cd495cdd47f";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
