{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0.1";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "c0d2b8858ccbf01e605a507706cf61fc1ae13d86c49fa0095bca1e45b7e940f1";
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
