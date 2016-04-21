{ stdenv
, fetchurl
, wrapPython

, python
, unzip
}:

let
  wheel_source = fetchurl {
    url = "https://pypi.python.org/packages/py2.py3/w/wheel/wheel-0.29.0-py2.py3-none-any.whl";
    sha256 = "ea8033fc9905804e652f75474d33410a07404c1a78dd3c949a66863bd1050ebd";
  };

  setuptools_source = fetchurl {
    url = "https://pypi.python.org/packages/py2.py3/s/setuptools/setuptools-20.9.0-py2.py3-none-any.whl";
    sha256 = "f8e38d3002085052bcc934053745152bac9979e6aa5649115794b34cde5fb180";
  };
in
stdenv.mkDerivation rec {
  name = "python-${python.version}-bootstrapped-pip-${version}";
  version = "8.1.1";

  src = fetchurl {
    url = "https://pypi.python.org/packages/py2.py3/p/pip/pip-${version}-py2.py3-none-any.whl";
    sha256 = "44b9c342782ab905c042c207d995aa069edc02621ddbdc2b9f25954a0fdac25c";
  };

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
