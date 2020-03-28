{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
, unzip

, appdirs
, packaging
, pyparsing
, six
}:

let
  inherit (lib)
    makeSearchPath;

  version = "46.1.3";
in
buildPythonPackage rec {
  name = "setuptools-${version}";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "795e0475ba6cd7fa082b1ee6e90d552209995627a2a227a47c6ea93282f4bfb1";
  };

  nativeBuildInputs = [
    unzip
  ];

  propagatedBuildInputs = [
    appdirs
    packaging
    pyparsing
    six
  ];

  postPatch = /* Remove vendored sources, otherwise no errors are returned */ ''
    rm -rv pkg_resources/_vendor/
  '';

  preBuild = ''
    ${python.interpreter} bootstrap.py
  '';

  passthru = {
    inherit version;
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
