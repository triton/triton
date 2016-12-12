{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "3.3.0";
in
buildPythonPackage rec {
  name = "fonttools-${version}";

  src = fetchPyPi {
    package = "fonttools";
    inherit version;
    type = ".zip";
    sha256 = "501bd76bc11381887589ce2343c2f480d6728fca8321487ab06be76a0a21df52";
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
