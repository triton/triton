{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.9";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "d819299c3aa8f85f248295ab8559e202af429b4017301b122a0b4c387aed10d2";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
