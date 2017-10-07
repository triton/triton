{ stdenv
, fetchurl
, lib

, bzip2
, fontconfig
, freetype
, libice
, libjpeg
, libpng
, libsm
, libtiff
, libx11
, opengl-dummy
, xorg
, zlib
}:

let
  inherit (lib)
    boolEn
    boolWt;

  version = "1.6.54";
in

assert xorg != null ->
  xorg.libXext != null
  && xorg.libXcursor != null
  && xorg.libXft != null
  && xorg.libXrandr != null
  && xorg.libXrender != null
  && xorg.renderproto != null
  && xorg.xproto != null;

stdenv.mkDerivation rec {
  name = "fox-${version}";

  src = fetchurl rec {
    url = "http://ftp.fox-toolkit.org/pub/${name}.tar.gz";
    multihash = "QmRSwf1L6juSt1sNZxiNzmGV8QcXtCR2PgWkg3H8y6gVDP";
    #sha1Url = url + ".sha1sum";
    sha256 = "960f16a8a69d41468f841039e83c2f58f3cb32622fc283a69f20381abb355219";
  };

  buildInputs = [
    bzip2
    fontconfig
    freetype
    libice
    libjpeg
    libpng
    libsm
    libtiff
    libx11
    opengl-dummy
    xorg.libXext
    xorg.libXcursor
    xorg.libXft
    xorg.libXrandr
    xorg.libXrender
    xorg.renderproto
    xorg.xproto
    zlib
  ];

  configureFlags = [
    "--disable-debug"
    "--enable-release"
    #"--disable-native"
    "--${boolEn (libjpeg != null)}-jpeg"
    #"--${boolEn (openjpeg != null)}-jp2"
    "--${boolEn (libpng != null)}-png"
    #"--${boolEn (libwebp != null)}-webp"
    "--${boolEn (libtiff != null)}-tiff"
    "--${boolEn (zlib != null)}-zlib"
    "--${boolEn (bzip2 != null)}-bz2lib"
    "--${boolWt (xorg != null)}-x"
    "--without-profiling"
    "--${boolWt (xorg != null)}-xft"
    "--${boolWt (xorg != null)}-xshm"
    "--${boolWt (xorg != null)}-shape"
    "--${boolWt (xorg != null)}-xcursor"
    "--${boolWt (xorg != null)}-xrender"
    "--${boolWt (xorg != null)}-xrandr"
    "--${boolWt (xorg != null)}-xfixes"
    "--${boolWt (xorg != null)}-xinput"
    "--${boolWt (xorg != null)}-xim"
    "--${boolWt (opengl-dummy != null)}-opengl"
  ];

  doCheck = true;

  meta = with lib; {
    description = "C++ based class library for Graphical User Interfaces";
    homepage = "http://fox-toolkit.org";
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
