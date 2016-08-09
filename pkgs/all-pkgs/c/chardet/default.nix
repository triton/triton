{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "chardet-${version}";
  version = "2.3.0";

  src = fetchPyPi {
    package = "chardet";
    inherit version;
    sha256 = "e53e38b3a4afe6d1132de62b7400a4ac363452dc5dfcf8d88e8e0cce663c68aa";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Universal encoding detector";
    homepage = https://github.com/chardet/chardet;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
