{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "mutagen-${version}";
  version = "1.36";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "d7ee37e33b8c5893c3ebf66edac31241eb9d48e1dc7ec647bbfbc180565a4bcd";
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
