{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.2.1";
in
buildPythonPackage rec {
  name = "hyperlink-${version}";

  src = fetchPyPi {
    package = "hyperlink";
    inherit version;
    sha256 = "2c74b35662416f44823d50e59305f761a933723ae6528cc5b0d711361453f28b";
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
