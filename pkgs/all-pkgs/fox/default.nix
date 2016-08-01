{ stdenv
, fetchurl

, bzip2
, fontconfig
, freetype
, libjpeg
, libpng
, libtiff
, mesa
, xorg
, zlib
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;

  version = "1.7.56";
in

assert xorg != null ->
  xorg.libICE != null
  && xorg.libSM != null
  && xorg.libX11 != null
  && xorg.libXext != null
  && xorg.libXcursor != null
  && xorg.libXft != null
  && xorg.libXrandr != null
  && xorg.libXrender != null
  && xorg.renderproto != null
  && xorg.xproto != null
  ;

stdenv.mkDerivation rec {
  name = "fox-${version}";

  src = fetchurl rec {
    url = "http://ftp.fox-toolkit.org/pub/${name}.tar.gz";
    sha1Url = url + ".sha1sum";
    sha256 = "41a03ff6a211c584e7547004002a1cfc768cdc32c84a46ec1499a4c345190885";
  };

  buildInputs = [
    bzip2
    fontconfig
    freetype
    libjpeg
    libpng
    libtiff
    mesa
    xorg.libICE
    xorg.libSM
    xorg.libX11
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
    "--disable-native"
    (enFlag "jpeg" (libjpeg != null) null)
    #(enFlag "jp2" (openjpeg != null) null)
    (enFlag "png" (libpng != null) null)
    #(enFlag "webp" (libwebp != null) null)
    (enFlag "tiff" (libtiff != null) null)
    (enFlag "zlib" (zlib != null) null)
    (enFlag "bz2lib" (bzip2 != null) null)
    (wtFlag "x" (xorg != null) null)
    "--without-profiling"
    (wtFlag "xft" (xorg != null) null)
    (wtFlag "xshm" (xorg != null) null)
    (wtFlag "shape" (xorg != null) null)
    (wtFlag "xcursor" (xorg != null) null)
    (wtFlag "xrender" (xorg != null) null)
    (wtFlag "xrandr" (xorg != null) null)
    (wtFlag "xfixes" (xorg != null) null)
    (wtFlag "xinput" (xorg != null) null)
    (wtFlag "xim" (xorg != null) null)
    (wtFlag "opengl" true null)
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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
