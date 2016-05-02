{ stdenv
, fetchFromGitHub
, perl

, efivar
, pciutils
, zlib
}:

stdenv.mkDerivation rec {
  name = "efibootmgr-${version}";
  version = "0.12";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "efibootmgr";
    rev = name;
    sha256 = "a6074d20b9b62a3e9e84fbe762594ecc0fd16578f36edf17e852b5d7b0b8efc1";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    efivar
    pciutils
    zlib
  ];

  postPatch = ''
    patchShebangs ./tools/install.pl
  '';

  NIX_CFLAGS_COMPILE = [
    "-I${efivar}/include/efivar"
  ];

  preInstall = ''
    installFlagsArray+=(
      "BINDIR=$out/sbin"
    )
  '';

  meta = with stdenv.lib; {
    description = "Application to modify the EFI Boot Manager";
    homepage = https://github.com/rhinstaller/efibootmgr;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
