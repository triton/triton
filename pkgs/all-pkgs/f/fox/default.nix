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
, libxext
, libxcursor
, libxft
, libxrandr
, libxrender
, opengl-dummy
, xorgproto
, zlib
}:

let
  inherit (lib)
    boolEn
    boolWt;

  version = "1.6.54";
in
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
    libxext
    libxcursor
    libxft
    libxrandr
    libxrender
    opengl-dummy
    xorgproto
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
    "--with-x"
    "--without-profiling"
    "--with-xft"
    "--with-xshm"
    "--with-shape"
    "--with-xcursor"
    "--with-xrender"
    "--with-xrandr"
    "--with-xfixes"
    "--with-xinput"
    "--with-xim"
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
