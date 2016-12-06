{ buildPythonPackage
, fetchPyPi
, lib

, audioread
, chromaprint
, requests
}:

let
  version = "1.1.3";
in
buildPythonPackage rec {
  name = "pyacoustid-${version}";

  src = fetchPyPi {
   package = "pyacoustid";
   inherit version;
   sha256 = "6e303cb34ad10a3a3b50f6b969ef3269a0b6f0fbe713b8e8ead800d47621c06f";
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
    homepage = "https://github.com/sampsyo/pyacoustid";
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
