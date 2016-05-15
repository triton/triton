{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "pynzb-${version}";
  version = "0.1.0";

  src = fetchPyPi {
    package = "pynzb";
    inherit version;
    sha256 = "0735b3889a1174bbb65418ee503629d3f5e4a63f04b16f46ffba18253ec3ef17";
  };

  doCheck = true;

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
