{ stdenv
, buildPythonPackage
, fetchFromGitHub
#, fetchPyPi
, lib
}:

let
  version = "0.28b1";
in
buildPythonPackage {
  name = "cython-${version}";

  # src = fetchPyPi {
  #   package = "Cython";
  #   inherit version;
  #   sha256 = "6a00512de1f2e3ce66ba35c5420babaef1fe2d9c43a8faab4080b0dbcc26bc64";
  # };

  # Temporary until 0.28 is released, needed for python 3.7 & gevent compatibility.
  src = fetchFromGitHub {
    version = 5;
    owner = "cython";
    repo = "cython";
    rev = version;
    sha256 = "f73cd82d52762041f20f3cb4a217eaa1d4377b5a2c33853e7a308f861218c06c";
  };

  meta = with lib; {
    description = "An optimising static compiler for the Python and Cython programming languages";
    homepage = http://cython.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
