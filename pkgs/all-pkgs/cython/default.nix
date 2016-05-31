{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.24";
in
buildPythonPackage {
  name = "Cython-${version}";

  src = fetchPyPi {
    package = "Cython";
    inherit version;
    sha256 = "6de44d8c482128efc12334641347a9c3e5098d807dd3c69e867fa8f84ec2a3f1";
  };

  meta = with stdenv.lib; {
    description = "An optimising static compiler for both the Python programming language and the extended Cython programming language";
    homepage = http://cython.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
