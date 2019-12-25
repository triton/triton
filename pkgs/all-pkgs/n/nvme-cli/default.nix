{ stdenv
, fetchFromGitHub
, lib

, util-linux_lib
}:

let
  version = "1.9";
in
stdenv.mkDerivation rec {
  name = "nvme-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "linux-nvme";
    repo = "nvme-cli";
    rev = "v${version}";
    sha256 = "3f714d717ef2ff7843f4675a8a02bdf77dbb09c98c5459c2859a858b5f2a2723";
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

  installFlags = [
    "SYSCONFDIR=${placeholder "out"}/etc"
  ];

  installTargets = [
    "install-spec"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
