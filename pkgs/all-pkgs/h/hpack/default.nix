{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "3.0.0";
in
buildPythonPackage {
  name = "hpack-${version}";

  src = fetchPyPi {
    package = "hpack";
    inherit version;
    sha256 = "8eec9c1f4bfae3408a3f30500261f7e6a65912dc138526ea054f9ad98892e9d2";
  };

  meta = with lib; {
    description = "HTTP/2 Header Encoding for Python";
    homepage = https://github.com/python-hyper/hpack;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
