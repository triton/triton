{ stdenv, lib, fetchurl, python, wrapPython }:

stdenv.mkDerivation rec {
  shortName = "setuptools-${version}";
  name = "${python.executable}-${shortName}";

  version = "20.6.7";  # 18.4 and up breaks python34Packages.characteristic and many others

  src = fetchurl {
    url = "https://pypi.python.org/packages/source/s/setuptools/${shortName}.tar.gz";
    sha256 = "d20152ee6337323d3b6d95cd733fb719d6b4f3fbc40f61f7a48e5a1bb96478b2";
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
