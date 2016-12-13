{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.7";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "d25da535d860a6712761ae88a29ba8b1211043a468cfeafb1b4335bc530368a5";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
