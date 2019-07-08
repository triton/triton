{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib
}:

let
  version = "0.6.1";
in
buildPythonPackage {
  name = "msgpack-python-${version}";

  src = fetchPyPi {
    package = "msgpack";
    inherit version;
    sha256 = "4008c72f5ef2b7936447dcb83db41d97e9791c83221be13d5e19db0796df1972";
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
