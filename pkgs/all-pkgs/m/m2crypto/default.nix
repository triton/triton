{ stdenv
, buildPythonPackage
, fetchPyPi

, openssl
, typing
}:

let
  version = "0.26.0";
in
buildPythonPackage {
  name = "M2Crypto-${version}";

  src = fetchPyPi {
    package = "M2Crypto";
    inherit version;
    sha256 = "05d94fd9b2dae2fb8e072819a795f0e05d3611b09ea185f68e1630530ec09ae8";
  };

  buildInputs = [
    openssl
  ];

  propagatedBuildInputs = [
    typing
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
