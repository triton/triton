{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pykwalify
, ruamel-yaml
}:

let
  version = "1.2.16";
in
buildPythonPackage {
  name = "borgmatic-${version}";

  src = fetchPyPi {
    package = "borgmatic";
    inherit version;
    sha256 = "9972e8b9d48015d70fc185a8351b3bdff156154ddae8458d2cabc840535df5fa";
  };

  propagatedBuildInputs = [
    pykwalify
    ruamel-yaml
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
