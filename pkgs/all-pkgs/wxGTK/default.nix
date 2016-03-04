{ stdenv
, fetchurl

, cairo
, gconf
, gstreamer_0
, gst-plugins-base_0
, gtk3
, expat
, libjpeg
, libmsgpack
, libnotify
, libpng
, libtiff
, mesa
, xorg
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "wxwidgets-${version}";
  version = "3.0.2";

  src = fetchurl {
    url = "mirror://sourceforge/wxwindows/wxWidgets-${version}.tar.bz2";
    sha256 = "0paq27brw4lv8kspxh9iklpa415mxi8zc117vbbbhfjgapf7js1l";
  };

  buildInputs = [
    cairo
    gconf
    gstreamer_0
    gst-plugins-base_0
    gtk3
    expat
    libjpeg
    libmsgpack
    libnotify
    libpng
    libtiff
    mesa
    xorg.libSM
    xorg.libX11
    xorg.libXinerama
    xorg.libXxf86vm
    xorg.xf86vidmodeproto
    xz
    zlib
  ];

  SEARCH_LIB = "${mesa}/lib";

  preConfigure = ''
    substituteInPlace configure --replace 'SEARCH_INCLUDE=' 'DUMMY_SEARCH_INCLUDE='
    substituteInPlace configure --replace 'SEARCH_LIB=' 'DUMMY_SEARCH_LIB='
    substituteInPlace configure --replace /usr /no-such-path
  '';

  configureFlags = [
    "--enable-monolithic"
    "--with-gtk=3"
    "--disable-precomp-headers"
    "--enable-mediactrl"
    "--enable-unicode"
    "--with-opengl"
  ];

  postInstall = ''
    pushd $out/include
    ln -sv wx-*/* .
    popd
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
