{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.3.9";
in
buildPythonPackage rec {
  name = "colorama-${version}";

  src = fetchPyPi {
    package = "colorama";
    inherit version;
    sha256 = "48eb22f4f8461b1df5734a074b57042430fb06e1d61bd1e11b078c0fe6d7a1f1";
  };

  meta = with lib; {
    description = "Cross-platform colored terminal text";
    homepage = https://github.com/tartley/colorama;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
