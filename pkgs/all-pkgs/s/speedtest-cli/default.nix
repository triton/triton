{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.0.2";
in
buildPythonPackage rec {
  name = "speedtest-cli-${version}";

  src = fetchPyPi {
    package = "speedtest-cli";
    inherit version;
    sha256 = "60cd286e1a8244100f4e4faf8f79d534c7df508daaf9d77f11196878846f7bff";
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
