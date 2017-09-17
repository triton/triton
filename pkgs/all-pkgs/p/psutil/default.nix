{ stdenv
, buildPythonPackage
, lib
, fetchPyPi
}:

let
  version = "5.3.1";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "12dd9c8abbad15f055e9579130035b38617020ce176f4a498b7870e6321ffa67";
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
