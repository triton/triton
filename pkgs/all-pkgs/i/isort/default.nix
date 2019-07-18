{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.3.21";
in
buildPythonPackage rec {
  name = "isort-${version}";

  src = fetchPyPi {
    package = "isort";
    inherit version;
    sha256 = "54da7e92468955c4fceacd0c86bd0ec997b0e1ee80d97f67c35a78b719dccab1";
  };

  meta = with lib; {
    description = "Library to sort Python imports";
    homepage = https://github.com/timothycrosley/isort;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
