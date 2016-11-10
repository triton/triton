{ stdenv
, fetchPyPi
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${version}";
  # Make sure to update pkgs/p/pip/bootstrap.nix setuptools hash when updating
  version = "28.8.0";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    sha256 = "432a1ad4044338c34c2d09b0ff75d509b9849df8cf329f4c1c7706d9c2ba3c61";
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
    bootstrapSha256 = "2e59d06ac798efce29c567ee0e0687514efca529a665b8f364cf497cd10d21b2";
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
