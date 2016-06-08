{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "psutil-${version}";
  version = "4.2.0";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "544f013a0aea7199e07e3efe5627f5d4165179a04c66050b234cc3be2eca1ace";
  };

  meta = with stdenv.lib; {
    description = "A process and system utilities module for Python";
    homepage = https://github.com/giampaolo/psutil/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
