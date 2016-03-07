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
    sha256 = "0fmrsp67dln76896fvxalj2pamyp9dszf32kl06wdfi0km42z8sh";
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

  NIX_LDFLAGS = [
    "-lefiboot"
    "-lefivar"
  ];

  installFlags = [
    "BINDIR=$(out)/sbin"
  ];

  meta = with stdenv.lib; {
    description = "Application to modify the EFI Boot Manager";
    homepage = https://github.com/rhinstaller/efibootmgr;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
