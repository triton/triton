{ stdenv
, buildPythonPackage
, fetchPyPi

, vcversioner
}:

let
  version = "2.5.1";
in
buildPythonPackage rec {
  name = "jsonschema-${version}";

  src = fetchPyPi {
    package = "jsonschema";
    inherit version;
    sha256 = "36673ac378feed3daa5956276a829699056523d7961027911f064b52255ead41";
  };

  propagatedBuildInputs = [
    vcversioner
  ];

  meta = with stdenv.lib; {
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
