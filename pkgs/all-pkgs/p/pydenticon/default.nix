{ stdenv
, buildPythonPackage
, fetchPyPi

, pillow
}:

let
  version = "0.3";
in
buildPythonPackage {
  name = "pydenticon-${version}";

  src = fetchPyPi {
    package = "pydenticon";
    inherit version;
    sha256 = "02041c589e629c330e420ded65192c79980b3a68fa91aee6179f46af6ad4e298";
  };

  buildInputs = [
    pillow
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
