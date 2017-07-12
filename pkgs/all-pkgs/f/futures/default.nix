{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, isPy3
}:

let
  version = "3.1.1";
in
buildPythonPackage rec {
  name = "futures-${version}";

  src = fetchPyPi {
    package = "futures";
    inherit version;
    sha256 = "51ecb45f0add83c806c68e4b06106f90db260585b25ef2abfcda0bd95c0132fd";
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
