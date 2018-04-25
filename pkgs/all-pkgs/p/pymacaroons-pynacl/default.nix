{ stdenv
, buildPythonPackage
, fetchFromGitHub

, pynacl
, six
}:

let
  version = "0.9.3";
in
buildPythonPackage {
  name = "pymacaroons-pynacl-${version}";
  
  src = fetchFromGitHub {
    version = 6;
    owner = "matrix-org";
    repo = "pymacaroons";
    rev = "v${version}";
    sha256 = "77c8c29d0e2bc5ca8cb449674fb644e02fd9a4dd343e3e7f55e3cb70d139f99f";
  };

  buildInputs = [
    pynacl
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
