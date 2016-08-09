{ stdenv
, fetchurl
, flex

, fontconfig
, libjpeg
, libpng
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "motif-2.3.6";

  src = fetchurl {
    url = "mirror://sourceforge/motif/${name}.tar.gz";
    sha256 = "fa810e6bedeca0f5a2eb8216f42129bcf6bd23919068d433e386b7bfc05d58cf";
  };

  nativeBuildInputs = [
    flex
  ];

  buildInputs = [
    fontconfig
    libjpeg
    libpng
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXmu
    xorg.libXp
    xorg.libXt
    xorg.printproto
    xorg.xbitmaps
    xorg.xproto
    xorg.xextproto
  ];

  configureFlags = [
    #"--enable-message-catalog"
    #"--enable-themes"
    "--enable-motif22-compatibility"
    "--enable-utf8"
    "--enable-printing"
    (enFlag "xft" (xorg.libXft != null) null)
    (enFlag "jpeg" (libjpeg != null) null)
    (enFlag "png" (libpng != null) null)
    (enFlag "x" (xorg != null) null)
  ];

  meta = with stdenv.lib; {
    description = "The Motif user interface component toolkit";
    homepage = https://motif.ics.com/;
    license = with licenses; [
      lgpl21Plus
      mit
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
