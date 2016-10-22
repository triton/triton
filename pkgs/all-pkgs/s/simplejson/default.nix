{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.9.0";
in
buildPythonPackage {
  name = "simplejson-${version}";

  src = fetchPyPi {
    package = "simplejson";
    inherit version;
    sha256 = "e9abeee37424f4bfcd27d001d943582fb8c729ffc0b74b72bd0e9b626ed0d1b6";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
