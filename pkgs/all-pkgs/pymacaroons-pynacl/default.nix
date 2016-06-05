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
    owner = "matrix-org";
    repo = "pymacaroons";
    rev = "v${version}";
    sha256 = "1aef4d8f75479fe4860e90dc2365f421e788977b586a138c0c31210762384c92";
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
