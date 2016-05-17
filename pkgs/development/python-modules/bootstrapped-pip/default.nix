{ stdenv
, fetchPyPi
, wrapPython

, pip
, python
, setuptools
, unzip
, wheel
}:

let
  wheel_source = fetchPyPi {
    package = "wheel";
    inherit (wheel) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "ea8033fc9905804e652f75474d33410a07404c1a78dd3c949a66863bd1050ebd";
  };

  setuptools_source = fetchPyPi {
    package = "setuptools";
    inherit (setuptools) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "fb6378f65eb630281227720ae80276f38c1a1f16969eca499435c0ff2a815fe6";
  };

  pip_source = fetchPyPi {
    package = "pip";
    inherit (pip) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "6464dd9809fb34fc8df2bf49553bb11dac4c13d2ffa7a4f8038ad86a4ccb92a1";
  };
in

stdenv.mkDerivation rec {
  name = "python-${python.version}-bootstrapped-pip-${version}";
  inherit (pip) version;

  src = pip_source;

  nativeBuildInputs = [
    wrapPython
    unzip
  ];

  unpackPhase = ''
    mkdir -p $out/${python.sitePackages}
    unzip -d $out/${python.sitePackages} $src
    unzip -d $out/${python.sitePackages} ${setuptools_source}
    unzip -d $out/${python.sitePackages} ${wheel_source}
  '';

  patchPhase = ''
    mkdir -p $out/bin
  '';

  installPhase = ''
    # install pip binary
    echo '${python.interpreter} -m pip "$@"' > $out/bin/pip
    chmod +x $out/bin/pip

    wrapPythonPrograms $out/bin
  '';
}
