{ stdenv
, autoreconfHook
, fetchpatch
, fetchurl
, ghostscript
}:

stdenv.mkDerivation {
  name = "ijs-${ghostscript.version}";

  inherit (ghostscript) src;

  nativeBuildInputs = [
    autoreconfHook
  ];

  postPatch = ''
    cd ijs
  '';

  configureFlags = [
    "--enable-shared"
  ];

  meta = with stdenv.lib; {
    homepage = https://www.openprinting.org/download/ijs/;
    description = "Raster printer driver architecture";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
