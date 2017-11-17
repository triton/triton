{ stdenv
, python
, six
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-six-bootstrap-${six.version}";

  inherit (six) meta src;

  installPhase = ''
    ${python.interpreter} setup.py install --root=/ --prefix=$out --no-compile
  '';
}
