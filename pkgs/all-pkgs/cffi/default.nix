{ stdenv
, buildPythonPackage
, fetchPyPi

, libffi
, pycparser
}:

let
  version = "1.7.0";
in
buildPythonPackage {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "6ed5dd6afd8361f34819c68aaebf9e8fc12b5a5893f91f50c9e50c8886bb60df";
  };

  propagatedBuildInputs = [
    pycparser
  ];

  buildInputs = [
    libffi
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
