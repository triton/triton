{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.4";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "0728815ef0c53d67fd437aa5220450a9752d41ecb28108f5df628a092ff466ea";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
