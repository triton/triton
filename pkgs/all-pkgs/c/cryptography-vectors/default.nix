{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.5.2";
in
buildPythonPackage {
  name = "cryptography_vectors-${version}";

  src = fetchPyPi {
    package = "cryptography_vectors";
    inherit version;
    sha256 = "d63c1bf182f9d9feb872594f2bf9ed2d98981c925bea45b019fe892047a35535";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
