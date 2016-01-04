{ stdenv, fetchurl, automake, autoconf, libtool, libzen, zlib, curl, libmms }:

stdenv.mkDerivation rec {
  version = "0.7.81";
  name = "libmediainfo-${version}";

  src = fetchurl {
    url = "http://mediaarea.net/download/source/libmediainfo/${version}/libmediainfo_${version}.tar.xz";
    sha256 = "0hzfrg7n7wlnwq28hmpxczis1k8x73wbwlsmfkshvqcwi7lva0cs";
  };

  nativeBuildInputs = [ automake autoconf libtool ];
  buildInputs = [ libzen zlib curl libmms ];

  sourceRoot = "./MediaInfoLib/Project/GNU/Library/";

  preConfigure = ''
    sh autogen.sh
    cat configure.ac
  '';

  configureFlags = [
    "--enable-shared"
    "--with-libcurl"
    "--with-libmms"
  ];

  postInstall = ''
    install -vD -m 644 libmediainfo.pc "$out/lib/pkgconfig/libmediainfo.pc"
  '';

  meta = {
    description = "Shared library for mediainfo";
    homepage = http://mediaarea.net/;
    license = stdenv.lib.licenses.bsd2;
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.devhell ];
  };
}
