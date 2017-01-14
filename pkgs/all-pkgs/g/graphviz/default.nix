{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, flex
, libtool
, swig

, cairo
, devil
, expat
, gts
, fontconfig
, libgd
, libjpeg
, libpng
, pango
, xorg
, zlib
}:

let
  inherit (stdenv.lib)
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
    md5Confirm = "4ea6fd64603536406166600bcc296fc8";
    sha256 = "ca5218fade0204d59947126c38439f432853543b0818d9d728c589dfe7f3a421";
  };

  nativeBuildInputs = [
    bison
    libtool
    swig
  ];

  buildInputs = [
    devil
    expat
    gts
    fontconfig
    libgd
    libjpeg
    libpng
    pango
    xorg.libICE
    xorg.libX11
    xorg.libXaw
    xorg.libXmu
    xorg.libXpm
    xorg.libXrender
    xorg.libXt
    xorg.xproto
    zlib
  ];

  configureFlags = [
    "--with-pngincludedir=${libpng}/include"
    "--with-pnglibdir=${libpng}/lib"
    "--with-jpegincludedir=${libjpeg}/include"
    "--with-jpeglibdir=${libjpeg}/lib"
    "--with-expatincludedir=${expat}/include"
    "--with-expatlibdir=${expat}/lib"
  ];

  preBuild = ''
    sed -e 's@am__append_5 *=.*@am_append_5 =@' -i lib/gvc/Makefile
  '';

  # "command -v" is POSIX, "which" is not
  postInstall = ''
    sed -i 's|`which lefty`|"'$out'/bin/lefty"|' $out/bin/dotty
    sed -i 's|which|command -v|' $out/bin/vimdot
  '';

  # Adding optimizations breaks the internal malloc build
  fortifySource = false;
  optimize = false;

  meta = with stdenv.lib; {
    description = "Open source graph visualization software";
    homepage = "http://www.graphviz.org/";
    license = licenses.free;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
