{ stdenv
, fetchurl

, bzip2
, freetype
, giflib
, libid3tag
, libjpeg
, libpng
, libtiff
, xorg
, zlib
}:

let
  version = "1.4.10";
in
stdenv.mkDerivation rec {
  name = "imlib2-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/imlib2-src/${version}/${name}.tar.bz2";
    sha256 = "3f698cd285cbbfc251c1d6405f249b99fafffafa5e0a5ecf0ca7ae49bbc0a272";
  };

  buildInputs = [
    bzip2
    freetype
    giflib
    libid3tag
    libjpeg
    libpng
    libtiff
    xorg.libICE
    xorg.libX11
    xorg.libXext
    xorg.xextproto
    xorg.xproto
    zlib
  ];

  preConfigure = ''
    sed -i 's,@my_libs@,,g' imlib2-config.in
  '';

  meta = with stdenv.lib; {
    description = "Image manipulation library";
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
