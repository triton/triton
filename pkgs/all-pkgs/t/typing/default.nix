{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.6.1";
in
buildPythonPackage {
  name = "typing-${version}";

  src = fetchPyPi {
    package = "typing";
    inherit version;
    sha256 = "c36dec260238e7464213dcd50d4b5ef63a507972f5780652e835d0228d0edace";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
