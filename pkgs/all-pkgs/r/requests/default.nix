{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.13.0";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "5722cd09762faa01276230270ff16af7acf7c5c45d623868d9ba116f15791ce8";
  };

  meta = with stdenv.lib; {
    description = "HTTP library for Python";
    homepage = http://python-requests.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
