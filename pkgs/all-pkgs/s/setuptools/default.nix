{ stdenv
, fetchPyPi
, lib
, unzip

, python
, wrapPython
}:

let
  # Make sure to update passthru.bootstrapSha256 setuptools hash when updating.
  version = "36.7.2";
in
stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${version}";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "ad86fd8dd09c285c33b4c5b82bbc21d21883637faef78b0ab58fa9984847220d";
  };

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
    ${python.interpreter} setup.py install --prefix=$out
    wrapPythonPrograms
  '';

  passthru = {
    inherit version;

    # Hash for pip bootstrap, see pkgs/p/pip/bootstrap.nix
    bootstrapSha256 = "bae92a71c82f818deb0b60ff1f7d764b8902cfc24187746b1aa6186918a70db3";
  };

  meta = with lib; {
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
