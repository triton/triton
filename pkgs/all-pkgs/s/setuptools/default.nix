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

  version = "40.0.0";
in
buildPythonPackage rec {
  name = "setuptools-${version}";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "012adb8e25fbfd64c652e99e7bab58799a3aaf05d39ab38561f69190a909015f";
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
