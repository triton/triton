{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.3.0";
in
buildPythonPackage {
  name = "priority-${version}";

  src = fetchPyPi {
    package = "priority";
    inherit version;
    sha256 = "6bc1961a6d7fcacbfc337769f1a382c8e746566aaa365e78047abe9f66b2ffbe";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
