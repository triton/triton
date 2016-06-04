{ stdenv
, buildPythonPackage
, fetchPyPi

, libffi
, pycparser
}:

let
  version = "1.6.0";
in
buildPythonPackage {
  name = "cffi-${version}";

  src = fetchPyPi {
    package = "cffi";
    inherit version;
    sha256 = "a7f75c4ef2362c0a0e54657add0a6c509fecbfa3b3807bc0925f5cb1c9f927db";
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
