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
    sha256 = "a037098401257659ec664ad0818a041b8b29f69172c274e2013d4399326bcb70";
  };

  pip_source = fetchPyPi {
    package = "pip";
    inherit (pip) version;
    type = "-py2.py3-none-any.whl";
    sha256 = "44b9c342782ab905c042c207d995aa069edc02621ddbdc2b9f25954a0fdac25c";
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
