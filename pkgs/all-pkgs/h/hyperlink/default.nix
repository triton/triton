{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "17.1.1";
in
buildPythonPackage rec {
  name = "hyperlink-${version}";

  src = fetchPyPi {
    package = "hyperlink";
    inherit version;
    sha256 = "a7462dee03672b8f853c26e1ab9e3b1fd4c90a6efde64ab44a851c2472445018";
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
