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

  version = "2.3.0";
in
buildPythonPackage {
  name = "pathlib2-${version}";

  src = fetchPyPi {
    package = "pathlib2";
    inherit version;
    sha256 = "d32550b75a818b289bd4c1f96b60c89957811da205afcceab75bc8b4857ea5b3";
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
