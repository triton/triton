{ stdenv
, fetchurl
, lib

, cairo
, giflib
, glib
, libexif
, libpng
, libtiff
, libx11
, pango
, xorgproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "libgdiplus-4.2";

  src = fetchurl {
    url = "https://download.mono-project.com/sources/libgdiplus/${name}.tar.gz";
    sha256 = "f332b9b8b44fd1c50b8d8d01a7296360b806c790b8297614739b3de1edbadfeb";
  };

  buildInputs = [
    cairo
    giflib
    glib
    libexif
    libpng
    libtiff
    libx11
    pango
    xorgproto
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--with-pango"
    "--with-libexif"
    "--with-libjpeg"
    "--with-libtiff"
    "--with-libgif"
  ];

  meta = with lib; {
    description = "C-based implementation of the GDI+ API";
    homepage = https://github.com/mono/libgdiplus;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
