{ buildPythonPackage
, fetchPyPi
, lib

, audioread
, chromaprint
, requests
}:

let
  version = "1.1.4";
in
buildPythonPackage rec {
  name = "pyacoustid-${version}";

  src = fetchPyPi {
   package = "pyacoustid";
   inherit version;
   sha256 = "b54bc803e936e49170f01febcf89621dda4a1ebb3d407e04e9ead290fa3a6cf3";
  };

  buildInputs = [
   chromaprint
  ];

  propagatedBuildInputs = [
    audioread
    requests
  ];

  meta = with lib; {
    description = "Bindings for Chromaprint acoustic fingerprinting";
    homepage = https://github.com/sampsyo/pyacoustid;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
