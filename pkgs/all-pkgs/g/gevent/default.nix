{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib

, greenlet
, libev
}:

let
  inherit (lib)
    optionals;

  version = "1.2.1";
in
buildPythonPackage rec {
  name = "gevent-${version}";

  src = fetchPyPi {
    package = "gevent";
    inherit version;
    sha256 = "3de300d0e32c31311e426e4d5d73b36777ed99c2bac3f8fbad939eeb2c29fa7c";
  };

  buildInputs = [
    libev
  ];

  propagatedBuildInputs = optionals (!isPyPy) [
    greenlet
  ];

  prePatch = ''
    rm -rf libev
  '';

  meta = with lib; {
    description = "Coroutine-based networking library";
    homepage = http://www.gevent.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
