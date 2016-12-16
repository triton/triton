{ stdenv
, fetchPyPi
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${version}";
  # Make sure to update pkgs/p/pip/bootstrap.nix setuptools hash when updating
  version = "32.0.0";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    sha256 = "45dc38f1a53296f4613f9421680f62a94b65ed535c3ac4d24f87f20ceed4a927";
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
    bootstrapSha256 = "e1d5a1fd8e7ac66e8f9ed2f0e5c08ac3c8d45a389c167ac0270b6580f365b558";
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
