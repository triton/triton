{ stdenv
, fetchurl
, flex
, lib

, fontconfig
, libice
, libjpeg
, libpng
, libsm
, libx11
, libxext
, libxft
, libxmu
, libxp
, libxt
, xorg
, xorgproto
}:

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
    libice
    libjpeg
    libpng
    libsm
    libx11
    libxext
    libxft
    libxmu
    libxp
    libxt
    xorg.xbitmaps
    xorgproto
  ];

  configureFlags = [
    #"--enable-message-catalog"
    #"--enable-themes"
    "--enable-motif22-compatibility"
    "--enable-utf8"
    "--enable-printing"
    "--enable-xft"
    "--enable-jpeg"
    "--enable-png"
    "--enable-x"
  ];

  meta = with lib; {
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
