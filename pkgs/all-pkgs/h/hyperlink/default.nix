{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "18.0.0";
in
buildPythonPackage rec {
  name = "hyperlink-${version}";

  src = fetchPyPi {
    package = "hyperlink";
    inherit version;
    sha256 = "f01b4ff744f14bc5d0a22a6b9f1525ab7d6312cb0ff967f59414bbac52f0a306";
  };

  meta = with lib; {
    description = "Fork of The Python Imaging Library (PIL)";
    homepage = http://python-pillow.org/;
    license = licenses.free; # PIL license
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
