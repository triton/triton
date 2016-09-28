{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.3.4";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "cd60a0f5cc3a745fd13322e563ffe49fea91880255c0d3c166ae04d4583826a6";
  };

  meta = with stdenv.lib; {
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
