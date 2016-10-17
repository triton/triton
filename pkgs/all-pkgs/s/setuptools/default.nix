{ stdenv
, fetchPyPi
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${version}";
  # Make sure to update pkgs/p/pip/bootstrap.nix setuptools hash when updating
  version = "28.6.0";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    sha256 = "4fdaf635f2ea815f914d94cfe2f7f856b5d46697defa68fcfb335870707bc2d9";
  };

  buildInputs = [
    python
    wrapPython
  ];

  installPhase = ''
    dst=$out/${python.sitePackages}
    mkdir -pv $dst
    export PYTHONPATH="$dst:$PYTHONPATH"
    ${python.interpreter} setup.py install --prefix=$out
    wrapPythonPrograms
  '';

  meta = with stdenv.lib; {
    description = "Utilities to facilitate the installation of Python packages";
    homepage = http://pypi.python.org/pypi/setuptools;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
