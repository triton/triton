{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, glibcLocales
}:

let
  version = "0.04.20";
in
buildPythonPackage rec {
  name = "Unidecode-${version}";

  src = fetchPyPi {
    package = "Unidecode";
    inherit version;
    sha256 = "ed4418b4b1b190487753f1cca6299e8076079258647284414e6d607d1f8a00e0";
  };

  buildInputs = [
    glibcLocales
  ];

  LC_ALL = "en_US.UTF-8";

  meta = with lib; {
    description = "ASCII transliterations of Unicode text";
    homepage = https://pypi.python.org/pypi/Unidecode/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
