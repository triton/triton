{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, scandir
, six
}:

let
  inherit (lib)
    optionals;

  version = "2.3.3";
in
buildPythonPackage {
  name = "pathlib2-${version}";

  src = fetchPyPi {
    package = "pathlib2";
    inherit version;
    sha256 = "25199318e8cc3c25dcb45cbe084cc061051336d5a9ea2a12448d3d8cb748f742";
  };

  propagatedBuildInputs = [
    scandir
    six
  ] ++ optionals (!isPy3) [
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
