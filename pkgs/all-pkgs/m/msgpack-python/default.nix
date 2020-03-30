{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib
}:

let
  version = "0.6.2";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack";
    inherit version;
    sha256 = "ea3c2f859346fcd55fc46e96885301d9c2f7a36d453f5d8f2967840efa1e1830";
  };

  nativeBuildInputs = [
    cython
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
