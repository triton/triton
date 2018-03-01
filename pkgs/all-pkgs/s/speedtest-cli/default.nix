{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0.0";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "b538898ed9308a9eb2a5f822669c1f859fe7a7b1237297b0afcd1c8d5105213d";
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
