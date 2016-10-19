{ stdenv
, fetchurl

, efivar
, popt
}:

let
  version = "14";
in
stdenv.mkDerivation rec {
  name = "efibootmgr-${version}";

  src = fetchurl {
    url = "https://github.com/rhinstaller/efibootmgr/releases/download/${version}/${name}.tar.bz2";
    sha256 = "377ec16484414b80afd1b8a586153d7ef55ccf048638080101d49b7c77f37ad8";
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
