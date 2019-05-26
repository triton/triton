{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.6";
in
buildPythonPackage rec {
  name = "rencode-${version}";

  src = fetchPyPi {
    package = "rencode";
    inherit version;
    sha256 = "2586435c4ea7d45f74e26765ad33d75309de7cf47c4d762e8efabd39905c0718";
  };

  meta = with lib; {
    description = "Object serialization similar to bencode";
    homepage = https://github.com/aresch/rencode;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

