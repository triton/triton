{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.3";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "e6897a11a8564b23e377fd63b8bdd895c015773ab0916d6a8358b996c423d653";
  };

  meta = with lib; {
    description = "CLI utility for testing internet bandwidth using speedtest.net";
    homepage = https://github.com/sivel/speedtest-cli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
