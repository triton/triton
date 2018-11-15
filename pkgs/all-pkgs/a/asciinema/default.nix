{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.0.1";
in
buildPythonPackage {
  name = "asciinema-${version}";

  src = fetchPyPi {
    package = "asciinema";
    inherit version;
    sha256 = "8d48baa3a263cfb9536540ee545e5c95e43758520d68c6ebc81a092e20c2a4ea";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
