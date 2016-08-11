{ stdenv
, fetchFromGitHub

, efivar
, popt
}:

stdenv.mkDerivation rec {
  name = "efibootmgr-2016-08-11";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "efibootmgr";
    rev = "0bb83cf5640ef834eb4c32a146d140c40034247b";
    sha256 = "940162b6960a7696767c39da250d49d27f4853bf3474b58355459bdaf4892760";
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
