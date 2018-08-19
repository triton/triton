{ stdenv
, fetchurl
, lib

, cairo
, devil
, expat
, gdk-pixbuf
, ghostscript
, glu
, gts
, fontconfig
, freeglut
, freetype
, libgd
, libice
, librsvg
, libsm
, libtool
, libx11
#, libxaw
, libxext
, libxmu
#, libxpm
, libxrender
, libxt
, opengl-dummy
, pango
, poppler
, xorg
, xorgproto
, zlib
}:

let
  inherit (lib)
    optional
    optionals
    optionalString;

  version = "2.40.1";
in
stdenv.mkDerivation rec {
  name = "graphviz-${version}";

  src = fetchurl {
    url = "http://www.graphviz.org/pub/graphviz/ARCHIVE/${name}.tar.gz";
    multihash = "QmdPD26wXCnji2yTGjkv2EqYNxtoVPC1f86neMjQ7dSJMZ";
    hashOutput = false;
    sha256 = "ca5218fade0204d59947126c38439f432853543b0818d9d728c589dfe7f3a421";
  };

  buildInputs = [
    # Main dependencies
    expat
    fontconfig
    freetype
    gts
    libtool

    # Graphical Deps
    freeglut
    glu
    libice
    libsm
    libx11
    #libxaw
    xorg.libXaw
    libxext
    libxmu
    libxt
    opengl-dummy
    xorgproto

    # Plugins
    devil
    gdk-pixbuf
    ghostscript
    libgd
    librsvg
    #libxpm
    xorg.libXpm
    libxrender
    pango
    poppler
    zlib
  ];

  # Make paths to binaries absolute
  preFixup = ''
    grep -q 'leftypath=' "$out"/bin/dotty
    sed -i "s,^leftypath=.*,^leftypath='$out'/bin/lefty," "$out"/bin/dotty
  '';

  # Adding optimizations breaks the internal malloc build
  fortifySource = false;
  optimize = false;

  passthru = {
    srcVerification = {
      failEarly = true;
      md5Confirm = "4ea6fd64603536406166600bcc296fc8";
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Open source graph visualization software";
    homepage = "http://www.graphviz.org/";
    license = licenses.free;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
