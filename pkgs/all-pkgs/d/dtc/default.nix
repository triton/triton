{ stdenv
, bison
, fetchzip
, flex
}:

let
  version = "1.4.4";
in
stdenv.mkDerivation rec {
  name = "dtc-${version}";

  src = fetchzip {
    version = 2;
    url = "https://git.kernel.org/pub/scm/utils/dtc/dtc.git/snapshot/v${version}.tar.xz";
    multihash = "Qmc7rFTTDpbv62vAZk5eroWu7koMJpuiMGfDbtG43BZheb";
    sha256 = "e2bc26528eb95e728c6b67d7f69d05eae468587498f6e18f5e731914ef0c3ebc";
  };

  nativeBuildInputs = [
    flex
    bison
  ];

  preInstall = ''
    installFlagsArray+=(
      "INSTALL=install"
      "PREFIX=$out"
    )
  '';

  meta = with stdenv.lib; {
    description = "Device Tree Compiler";
    homepage = https://git.kernel.org/cgit/utils/dtc/dtc.git;
    license = licenses.gpl2; # dtc itself is GPLv2, libfdt is dual GPL/BSD
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
