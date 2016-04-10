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
    sha256 = "bf941f9c29315d7606c5e64c07d0f53ef9e5d5e63083e85c04035e38ffe92249";
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
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
