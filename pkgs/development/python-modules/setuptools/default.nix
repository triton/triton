{ stdenv, lib, fetchPyPi, python, wrapPython }:

stdenv.mkDerivation rec {
  shortName = "setuptools-${version}";
  name = "${python.executable}-${shortName}";

  version = "20.10.1";  # 18.4 and up breaks python34Packages.characteristic and many others

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    sha256 = "3e59c885f09ed0d631816468e431b347b5103339e77a21cbf56df6283319b5dd";
  };

  buildInputs = [ python wrapPython ];
  doCheck = false;  # requires pytest
  installPhase = ''
      dst=$out/${python.sitePackages}
      mkdir -p $dst
      export PYTHONPATH="$dst:$PYTHONPATH"
      ${python.interpreter} setup.py install --prefix=$out
      wrapPythonPrograms
  '';

  meta = with stdenv.lib; {
    description = "Utilities to facilitate the installation of Python packages";
    homepage = http://pypi.python.org/pypi/setuptools;
    license = with lib.licenses; [ zpt20 ];
    platforms = platforms.all;
  };
}
