{ stdenv
, buildPythonPackage
, fetchFromGitHub
#, fetchPyPi
, lib
}:

let
  version = "2018-03-03";
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
    rev = "e8d309655fe0b80d8e10e35b852ccf9bf3045483";
    sha256 = "0d9ed34ae5f3eb73950fd8df6eb4b8db3246e8f6318af7287a9f6ac82e248d3b";
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
