{ stdenv, lib, fetchurl, python, wrapPython }:

stdenv.mkDerivation rec {
  shortName = "setuptools-${version}";
  name = "${python.executable}-${shortName}";

  version = "20.7.0";  # 18.4 and up breaks python34Packages.characteristic and many others

  src = fetchurl {
    url = "https://pypi.python.org/packages/source/s/setuptools/${shortName}.tar.gz";
    sha256 = "505cdf282c5f6e3a056e79f0244b8945f3632257bba8469386c6b9b396400233";
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
