{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
}:

let
  version = "3.3.0";
in
buildPythonPackage rec {
  name = "futures-${version}";

  src = fetchPyPi {
    package = "futures";
    inherit version;
    sha256 = "7e033af76a5e35f58e56da7a91e687706faf4e7bdfb2cbc3f2cca6b9bcda9794";
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
