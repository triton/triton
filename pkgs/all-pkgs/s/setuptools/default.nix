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
    PYTHONPATH="$dst" ${python.interpreter} setup.py install --prefix=$out
  '';

  preFixup = ''
    wrapPythonPrograms
  '';

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
