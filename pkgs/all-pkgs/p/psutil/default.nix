{ stdenv
, buildPythonPackage
, lib
, fetchPyPi
}:

let
  version = "5.4.5";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "ebe293be36bb24b95cdefc5131635496e88b17fabbcf1e4bc9b5c01f5e489cfe";
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
