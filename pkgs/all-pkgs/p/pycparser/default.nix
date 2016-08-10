{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.14";
in
buildPythonPackage {
  name = "pycparser-${version}";
  
  src = fetchPyPi {
    package = "pycparser";
    inherit version;
    sha256 = "7959b4a74abdc27b312fed1c21e6caf9309ce0b29ea86b591fd2e99ecdf27f73";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
