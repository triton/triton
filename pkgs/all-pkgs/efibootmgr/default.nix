{ stdenv
, fetchFromGitHub

, efivar
, popt
}:

stdenv.mkDerivation rec {
  name = "efibootmgr-2016-07-01";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "efibootmgr";
    rev = "94a9adc005073af7725cf5a54018544f68bfa03f";
    sha256 = "8c5e8b039e178cd3e39e93abea7627b9a52d60b308dacebeb106e3f7bae656b8";
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
