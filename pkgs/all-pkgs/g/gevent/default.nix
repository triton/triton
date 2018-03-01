{ stdenv
, buildPythonPackage
, cython
, fetchFromGitHub
#, fetchPyPi
, isPy3
, isPyPy
, lib
, python

, dnspython
, greenlet
, idna
, libev
}:

let
  inherit (lib)
    optionals;

  version = "2018-02-28";
  #version = "1.2.2";
in
buildPythonPackage rec {
  name = "gevent-${version}";

  # src = fetchPyPi {
  #   package = "gevent";
  #   inherit version;
  #   sha256 = "4791c8ae9c57d6f153354736e1ccab1e2baf6c8d9ae5a77a9ac90f41e2966b2d";
  # };

  # Switch back to stable releases once 1.3 is released.
  src = fetchFromGitHub {
    version = 5;
    owner = "gevent";
    repo = "gevent";
    rev = "a6844125377cdc7002166d9be00b17900674568a";
    sha256 = "596a86b94817100c0143bf9bd71c7a8003ec7abbfcfdc4ceed5f9a35232325fe";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    libev
  ];

  propagatedBuildInputs = optionals (!isPyPy) [
    greenlet
  ] ++ [
    dnspython
    idna
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${greenlet}/include/${python.executable}${if isPy3 then "m" else ""}"
  ];

  buildDirCheck = false;  # FIXME

  meta = with lib; {
    description = "Coroutine-based networking library";
    homepage = http://www.gevent.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
