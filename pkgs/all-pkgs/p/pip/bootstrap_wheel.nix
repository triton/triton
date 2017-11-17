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
    sha256 = "e721e53864f084f956f40f96124a74da0631ac13fbbd1ba99e8e2b5e9cafdf64";
  };

  setuptools_source = pythonPackages.fetchPyPi {
    package = "setuptools";
    inherit (pythonPackages.setuptools) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "bae92a71c82f818deb0b60ff1f7d764b8902cfc24187746b1aa6186918a70db3";
  };

  pip_source = pythonPackages.fetchPyPi {
    package = "pip";
    #inherit (pythonPackages.pip) version;
    version = "9.0.1";
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
