{ stdenv
, fetchPyPi
, setuptools
, unzip
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${setuptools.version}";
  # # Make sure to update pkgs/p/pip/bootstrap.nix setuptools hash when updating
  # version = "32.3.1";
  #
  # src = fetchPyPi {
  #   package = "setuptools";
  #   inherit version;
  #   type = ".zip";
  #   sha256 = "806bae0840429c13f6e6e44499f7c0b87f3b269fdfbd815d769569c1daa7c351";
  # };

  inherit (setuptools) meta src;

  nativeBuildInputs = [
    unzip
  ];

  buildInputs = [
    python
    wrapPython
  ];

  installPhase = ''
    dst=$out/${python.sitePackages}
    mkdir -pv $dst
    export PYTHONPATH="$dst:$PYTHONPATH"
    ${python.interpreter} setup.py install --prefix=$out --no-compile
    wrapPythonPrograms
  '';
}
