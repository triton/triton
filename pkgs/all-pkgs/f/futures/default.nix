{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, isPy3
}:

let
  version = "3.2.0";
in
buildPythonPackage rec {
  name = "futures-${version}";

  src = fetchPyPi {
    package = "futures";
    inherit version;
    sha256 = "9ec02aa7d674acb8618afb127e27fde7fc68994c0437ad759fa094a574adb265";
  };

  # This module is for backporting Python 3.2 functionality to Python 2.x.
  disabled = isPy3;

  meta = with lib; {
    description = "Backport of the concurrent.futures package from Python 3.2";
    homepage = https://github.com/agronholm/pythonfutures;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
