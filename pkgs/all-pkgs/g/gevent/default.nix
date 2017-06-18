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

  version = "1.2.2";
in
buildPythonPackage rec {
  name = "gevent-${version}";

  src = fetchPyPi {
    package = "gevent";
    inherit version;
    sha256 = "4791c8ae9c57d6f153354736e1ccab1e2baf6c8d9ae5a77a9ac90f41e2966b2d";
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
