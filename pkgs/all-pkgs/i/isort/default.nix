{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.3.4";
in
buildPythonPackage rec {
  name = "isort-${version}";

  src = fetchPyPi {
    package = "isort";
    inherit version;
    sha256 = "b9c40e9750f3d77e6e4d441d8b0266cf555e7cdabdcff33c4fd06366ca761ef8";
  };

  meta = with lib; {
    description = "Library to sort Python imports";
    homepage = https://github.com/timothycrosley/isort;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
