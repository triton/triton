{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, glibcLocales
}:

let
  version = "0.04.21";
in
buildPythonPackage rec {
  name = "Unidecode-${version}";

  src = fetchPyPi {
    package = "Unidecode";
    inherit version;
    sha256 = "280a6ab88e1f2eb5af79edff450021a0d3f0448952847cd79677e55e58bad051";
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
