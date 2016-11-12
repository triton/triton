{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "mutagen-${version}";
  version = "1.35.1";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "49cda72ee5213e60d5d48a80187b0b17d37a6244f37751f72e480c1b1832934e";
  };

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Python multimedia tagging library";
    homepage = https://github.com/quodlibet/mutagen;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
