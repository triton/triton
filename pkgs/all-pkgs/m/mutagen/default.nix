{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "mutagen-${version}";
  version = "1.34";

  src = fetchPyPi {
    package = "mutagen";
    inherit version;
    sha256 = "baf089121710c36ce317d9f107d552a3c7ec14dfcaa9618b809c4b25ef775619";
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
