{ stdenv
, buildPythonPackage
, lib
, fetchPyPi
}:

let
  version = "5.6.0";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "dca71c08335fbfc6929438fe3a502f169ba96dd20e50b3544053d6be5cb19d82";
  };

  meta = with lib; {
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
