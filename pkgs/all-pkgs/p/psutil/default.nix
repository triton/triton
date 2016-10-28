{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "4.4.2";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "1c37e6428f7fe3aeea607f9249986d9bb933bb98133c7919837fd9aac4996b07";
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
