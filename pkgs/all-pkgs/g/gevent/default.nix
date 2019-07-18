{ stdenv
, buildPythonPackage
, cython
, fetchFromGitHub
, fetchPyPi
, isPy3
, isPyPy
, lib
, python

, c-ares
, cffi
, dnspython
, greenlet
, idna
, libev
, libuv
, psutil
, zope-event
, zope-interface
}:

let
  version = "2019-06-11";
  #version = "1.4.0";
in
buildPythonPackage rec {
  name = "gevent-${version}";

  #src = fetchPyPi {
  #  package = "gevent";
  #  inherit version;
  #  sha256 = "1eb7fa3b9bd9174dfe9c3b59b7a09b768ecd496debfc4976a9530a3e15c990d1";
  #};

  # Latest release (1.4.0) does not configure CFFI modules correctly.
  src = fetchFromGitHub {
    version = 6;
    owner = "gevent";
    repo = "gevent";
    rev = "0283cffee5d3b2e0fe15e76982c5cf13180c1772";
    sha256 = "a90f794f87f374c05828b4d9d91f196373c74ecb3dce3c46ee74f1dab7d746d0";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    c-ares
    libev
    libuv
  ];

  propagatedBuildInputs = [
    cffi
    dnspython
    idna
    zope-event
    zope-interface
  ] ++ lib.optionals (!isPyPy) [
    greenlet
    psutil
  ];

  postPatch = /* Disable vendored sources */ ''
    sed -i _setupares.py \
      -i _setuplibev.py \
      -i src/gevent/libuv/_corecffi_build.py \
      -e 's,./configure,non-existant-command,' \
      -e 's/_setuputils.should_embed(.*)/False/' \
      -e 's/should_embed(.*)/False/'
  '';

  NIX_CFLAGS_COMPILE = lib.optionals (!isPyPy) [
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
