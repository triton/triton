{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.3.1";
in
buildPythonPackage rec {
  name = "hyperlink-${version}";

  src = fetchPyPi {
    package = "hyperlink";
    inherit version;
    sha256 = "bc4ffdbde9bdad204d507bd8f554f16bba82dd356f6130cb16f41422909c33bc";
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
