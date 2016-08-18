{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.1.0";
in
buildPythonPackage rec {
  name = "pynzb-${version}";

  src = fetchPyPi {
    package = "pynzb";
    inherit version;
    sha256 = "0735b3889a1174bbb65418ee503629d3f5e4a63f04b16f46ffba18253ec3ef17";
  };

  meta = with stdenv.lib; {
    description = "Unified API for parsing NZB files";
    homepage = http://github.com/ericflo/pynzb;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
