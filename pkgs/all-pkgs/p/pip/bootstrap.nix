{ stdenv
, pythonPackages

, unzip
, wrapPython
}:

let
  wheel_source = pythonPackages.fetchPyPi {
    package = "wheel";
    inherit (pythonPackages.wheel) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "ea8033fc9905804e652f75474d33410a07404c1a78dd3c949a66863bd1050ebd";
  };

  setuptools_source = pythonPackages.fetchPyPi {
    package = "setuptools";
    inherit (pythonPackages.setuptools) version;
    type = "-py2.py3-none-any.whl";
    sha256 = pythonPackages.setuptools.bootstrapSha256;
  };

  pip_source = pythonPackages.fetchPyPi {
    package = "pip";
    inherit (pythonPackages.pip) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "690b762c0a8460c303c089d5d0be034fb15a5ea2b75bdf565f40421f542fefb0";
  };
in

stdenv.mkDerivation rec {
  name = "python-${pythonPackages.python.version}-pip-bootstrap-${version}";
  inherit (pythonPackages.pip) version;

  src = pip_source;

  nativeBuildInputs = [
    wrapPython
    unzip
  ];

  unpackPhase = ''
    mkdir -p $out/${pythonPackages.python.sitePackages}
    unzip -d $out/${pythonPackages.python.sitePackages} $src
    unzip -d $out/${pythonPackages.python.sitePackages} ${setuptools_source}
    unzip -d $out/${pythonPackages.python.sitePackages} ${wheel_source}
  '';

  patchPhase = ''
    mkdir -p $out/bin
  '';

  installPhase = ''
    # install pip binary
    echo '${pythonPackages.python.interpreter} -m pip "$@"' > $out/bin/pip
    chmod +x $out/bin/pip

    wrapPythonPrograms $out/bin
  '';
}
