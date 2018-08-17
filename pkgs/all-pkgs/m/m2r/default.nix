{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, mistune
}:

let
  version = "0.2.0";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "b64ee5ac870311a69967fe787be8607df67b02a329f0fc76c8bf477336a99c78";
  };

  propagatedBuildInputs = [
    docutils
    mistune
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
