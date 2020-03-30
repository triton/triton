{ stdenv
, fetchFromGitHub
, lib

, util-linux_lib
}:

let
  version = "1.10.1";
in
stdenv.mkDerivation rec {
  name = "nvme-cli-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "linux-nvme";
    repo = "nvme-cli";
    rev = "v${version}";
    sha256 = "c825f39d5ef28c91f0f1c7e341edc333084fd4c69fa476e9c016758e99411b94";
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
