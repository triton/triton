{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.22";
in
buildPythonPackage rec {
  name = "Unidecode-${version}";

  src = fetchPyPi {
    package = "Unidecode";
    inherit version;
    sha256 = "8c33dd588e0c9bc22a76eaa0c715a5434851f726131bd44a6c26471746efabf5";
  };

  meta = with lib; {
    description = "ASCII transliterations of Unicode text";
    homepage = https://pypi.python.org/pypi/Unidecode/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
