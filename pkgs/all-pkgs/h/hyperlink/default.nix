{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "19.0.0";
in
buildPythonPackage rec {
  name = "hyperlink-${version}";

  src = fetchPyPi {
    package = "hyperlink";
    inherit version;
    sha256 = "4288e34705da077fada1111a24a0aa08bb1e76699c9ce49876af722441845654";
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
