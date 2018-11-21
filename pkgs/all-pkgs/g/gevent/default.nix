{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
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

  version = "1.3.7";
in
buildPythonPackage rec {
  name = "gevent-${version}";

  src = fetchPyPi {
    package = "gevent";
    inherit version;
    sha256 = "3f06f4802824c577272960df003a304ce95b3e82eea01dad2637cc8609c80e2c";
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

  meta = with lib; {
    description = "Coroutine-based networking library";
    homepage = http://www.gevent.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
