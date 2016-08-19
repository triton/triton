{ stdenv
, fetchurl

, efivar
, popt
}:

let
  version = "13";
in
stdenv.mkDerivation rec {
  name = "efibootmgr-${version}";

  src = fetchurl {
    url = "https://github.com/rhinstaller/efibootmgr/releases/download/${version}/${name}.tar.bz2";
    sha256 = "45d31914454bd4b8d9b2c4489c7f35c5e8588ea63a1cec5686b83a9633d678e1";
  };

  buildInputs = [
    efivar
    popt
  ];

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  NIX_CFLAGS_COMPILE = [
    "-I${efivar}/include/efivar"
  ];

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
