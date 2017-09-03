{ stdenv
, buildPythonPackage
, lib
, fetchPyPi
}:

let
  version = "5.3.0";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "a3940e06e92c84ab6e82b95dad056241beea93c3c9b1d07ddf96485079855185";
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
