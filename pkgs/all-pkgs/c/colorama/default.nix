{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.3.7";
in
buildPythonPackage rec {
  name = "colorama-${version}";

  src = fetchPyPi {
    package = "colorama";
    inherit version;
    sha256 = "e043c8d32527607223652021ff648fbb394d5e19cba9f1a698670b338c9d782b";
  };

  meta = with stdenv.lib; {
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
