{ stdenv
, fetchFromGitHub
, lib

, util-linux_lib
}:

let
  version = "1.8.1";
in
stdenv.mkDerivation rec {
  name = "nvme-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "linux-nvme";
    repo = "nvme-cli";
    rev = "v${version}";
    sha256 = "81f27d969d3c9de8682be11d8dfcaaeafde258c2a1a0e2881bc6bfded0fa3e6b";
  };

  buildInputs = [
    util-linux_lib
  ];

  postPatch = ''
    sed -i 's,-Werror,,' Makefile
  '';

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
