{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.0.0";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "6e825a6e1348cb4ae755cd28c9c640cae6fa8e8129419aea3693399b46386671";
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
