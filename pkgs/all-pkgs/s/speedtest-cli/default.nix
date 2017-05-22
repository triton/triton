{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.6";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "274bafa237426ae796e2f9120d584b31692431554ec7ab693bc46b90fb32088a";
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
