{ stdenv
, autoreconfHook
, fetchFromGitLab
, lib
}:

let
  version = "2.3.1";
in
stdenv.mkDerivation {
  name = "iucode-tool-${version}";

  src = fetchFromGitLab {
    version = 6;
    owner = "iucode-tool";
    repo = "iucode-tool";
    rev = "v${version}";
    multihash = "QmfB8xPsrTwBupiz7HCzrcbcaeqgDMHUt3Qc4yjopce3RX";
    sha256 = "52056cd3d3b92b1cd3eeac83683592f88dcbaa48fdf0852c039e208c867b13eb";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
