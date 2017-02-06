{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.2.1";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "06b9cdfb14e81e7a3b9c0f63ab19bc3b9bfc5cd372d766179884c0703c2213e8";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
