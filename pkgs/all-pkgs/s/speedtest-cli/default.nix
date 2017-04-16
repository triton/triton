{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.4";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "6f61ef7e2cb9265b1685dbcc0c53fe8073367cda142356286712c2c4f0554f14";
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
