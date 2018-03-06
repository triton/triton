{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib
}:

let
  version = "0.5.6";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack";
    inherit version;
    sha256 = "0ee8c8c85aa651be3aa0cd005b5931769eaa658c948ce79428766f1bd46ae2c3";
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
