{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "mutagen-${version}";
  version = "1.34.1";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "aacd667ef1f4fa7b7c201f36b2a6eda1ead3c92331017601d8082af62a7ee461";
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
