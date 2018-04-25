{ stdenv
, fetchFromGitHub
, lib

, util-linux_lib
}:

let
  version = "1.5";
in
stdenv.mkDerivation rec {
  name = "nvme-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "linux-nvme";
    repo = "nvme-cli";
    rev = "v${version}";
    sha256 = "045244031db9f9b0fd51c033d98f1e0d9cf2fb47efaf3740014cb975470f0396";
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
