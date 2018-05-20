{ stdenv
, fetchurl
, lib

, cairo
, gconf
, glu
, gstreamer
, gst-plugins-base
, gtk3
, expat
, libice
, libjpeg
, libnotify
, libpng
, libsm
, libtiff
, libx11
, libxinerama
, msgpack-c
, opengl-dummy
, xorg
, xorgproto
, xz
, zlib
}:

let
  version = "3.1.0";
in
stdenv.mkDerivation rec {
  name = "wxWidgets-${version}";

  src = fetchurl {
    url = "https://github.com/wxWidgets/wxWidgets/releases/download/v${version}/${name}.tar.bz2";
    sha1Confirm = "2170839cfa9d9322e8ee8368b21a15a2497b4f11";
    sha256 = "e082460fb6bf14b7dd6e8ac142598d1d3d0b08a7b5ba402fdbf8711da7e66da8";
  };

  buildInputs = [
    cairo
    gconf
    glu
    gstreamer
    gst-plugins-base
    expat
    libice
    libjpeg
    libnotify
    libpng
    libsm
    libtiff
    libx11
    libxinerama
    msgpack-c
    opengl-dummy
    xorg.libXxf86vm
    xorgproto
    xz
    zlib
  ];

  # WXWidget applications will depend directly on gtk
  propagatedBuildInputs = [
    gtk3
  ];

  SEARCH_LIB = "${opengl-dummy}/lib";

  preConfigure = ''
    sed -i configure \
      -e 's/SEARCH_INCLUDE=/DUMMY_SEARCH_INCLUDE=/' \
      -e 's/SEARCH_LIB=/DUMMY_SEARCH_LIB=/' \
      -e 's,/usr,/no-such-path,'
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

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
