{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.10.0";
in
buildPythonPackage {
  name = "simplejson-${version}";

  src = fetchPyPi {
    package = "simplejson";
    inherit version;
    sha256 = "953be622e88323c6f43fad61ffd05bebe73b9fd9863a46d68b052d2aa7d71ce2";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
