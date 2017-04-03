{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k
, lib

, scandir
, six
}:

let
  inherit (lib)
    optionals;

  version = "2.2.1";
in
buildPythonPackage {
  name = "pathlib2-${version}";

  src = fetchPyPi {
    package = "pathlib2";
    inherit version;
    sha256 = "ce9007df617ef6b7bd8a31cd2089ed0c1fed1f7c23cf2bf1ba140b3dd563175d";
  };

  propagatedBuildInputs = [
    scandir
    six
  ] ++ optionals (!isPy3k) [
    scandir
  ];

  meta = with lib; {
    description = "Object-oriented filesystem paths";
    homepage = https://pypi.python.org/pypi/pathlib2/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
