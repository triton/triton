{ stdenv
, fetchPyPi
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${version}";
  # Make sure to update pkgs/p/pip/bootstrap.nix setuptools hash when updating
  version = "30.2.0";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    sha256 = "f865709919903e3399343c0b3c42f95e9aeddc41e38cfb334fb2bb5dfa384857";
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

  passthru = {
    # Hash for pip bootstrap, see pkgs/p/pip/bootstrap.nix
    bootstrapSha256 = "b7e7b28d6a728ea38953d66e12ef400c3c153c523539f1b3997c5a42f3770ff1";
  };

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
