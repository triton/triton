{ stdenv
, fetchurl

, efivar
, popt
}:

let
  version = "16";
in
stdenv.mkDerivation rec {
  name = "efibootmgr-${version}";

  src = fetchurl {
    url = "https://github.com/rhinstaller/efibootmgr/releases/download/${version}/${name}.tar.bz2";
    sha256 = "950795fb4b58a09fb69e93c120d624000253f1241134469495c7a9def731f65f";
  };

  buildInputs = [
    efivar
    popt
  ];

  EFIDIR = "BOOT";

  preBuild = ''
    makeFlagsArray+=(
      "prefix=$out"
      "libdir=$out/lib" # should not be $out/lib64
    )
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
