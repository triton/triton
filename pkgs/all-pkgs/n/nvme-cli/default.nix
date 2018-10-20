{ stdenv
, fetchFromGitHub
, lib

, util-linux_lib
}:

let
  version = "1.6";
in
stdenv.mkDerivation rec {
  name = "nvme-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "linux-nvme";
    repo = "nvme-cli";
    rev = "v${version}";
    sha256 = "3f881dbbe1e5976f3b694bdcebbd23f6e7a1d218ebd63becc0b8ea86ecdfbdf7";
  };

  buildInputs = [
    util-linux_lib
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
