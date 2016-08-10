{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.4.2";
in
buildPythonPackage {
  name = "pycryptodomex-${version}";

  src = fetchPyPi {
    package = "pycryptodomex";
    inherit version;
    sha256 = "66489980aa0dd97dce28171c5f42e9862d33cc354a518e52a7bad0699d9b402a";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
