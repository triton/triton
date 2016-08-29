{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.0";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    sha256 = "df92dc0ad80eaf3c67c0ce48dd4c8dcc1027266f9bb128157cc30fb72e5d9138";
  };

  meta = with stdenv.lib; {
    description = "Library for manipulating fonts";
    homepage = https://github.com/behdad/fonttools;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
