{ buildPythonPackage
, fetchPyPi
, lib

, audioread
, chromaprint
, requests
}:

let
  version = "1.1.5";
in
buildPythonPackage rec {
  name = "pyacoustid-${version}";

  src = fetchPyPi {
   package = "pyacoustid";
   inherit version;
   sha256 = "efb6337a470c9301a108a539af7b775678ff67aa63944e9e04ce4216676cc777";
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
