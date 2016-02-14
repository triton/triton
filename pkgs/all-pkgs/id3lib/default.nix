{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl

, zlib
}:

stdenv.mkDerivation rec {
  name = "id3lib-3.8.3";

  src = fetchurl {
    url = "mirror://sourceforge/id3lib/${name}.tar.gz";
    sha256 = "0yfhqwk0w8q2hyv1jib1008jvzmwlpsxvc8qjllhna6p1hycqj97";
  };

  patches = [
    (fetchTritonPatch {
      rev = "9789c88d7d88911c8f9dbab6669c1b603b87f88b";
      file = "id3lib/id3lib-3.8.3-autoconf259.patch";
      sha256 = "ffde572cb263cce4585292143a4396ebd12592ac34b398da19d1608f1c2374f9";
    })
    (fetchTritonPatch {
      rev = "9789c88d7d88911c8f9dbab6669c1b603b87f88b";
      file = "id3lib/id3lib-3.8.3-doxyinput.patch";
      sha256 = "e7cd2eafe39229fee1195524872be3465d247590b7ead4a9cfa2178102a3d9ea";
    })
    (fetchTritonPatch {
      rev = "9789c88d7d88911c8f9dbab6669c1b603b87f88b";
      file = "id3lib/id3lib-3.8.3-gcc-4.3.patch";
      sha256 = "536f6bb5dddd48df3c7fc080c04f03a2053ab11429094f2f31d6e2d5f21a987e";
    })
    (fetchTritonPatch {
      rev = "9789c88d7d88911c8f9dbab6669c1b603b87f88b";
      file = "id3lib/id3lib-3.8.3-missing_nullpointer_check.patch";
      sha256 = "98a6a9a99474f8166a112e68956da25711ba3e2f7b503dd044f2161e525052e6";
    })
    (fetchTritonPatch {
      rev = "9789c88d7d88911c8f9dbab6669c1b603b87f88b";
      file = "id3lib/id3lib-3.8.3-zlib.patch";
      sha256 = "0b5531089422bda659deddcccf0562fcaa96529e74778065e35c848d6cf2a502";
    })
    (fetchTritonPatch {
      rev = "9789c88d7d88911c8f9dbab6669c1b603b87f88b";
      file = "id3lib/id3lib-3.8.3-unicode16.patch";
      sha256 = "71c79002d9485965a3a93e87ecbd7fed8f89f64340433b7ccd263d21385ac969";
    })
  ];

  postPatch =
  /* Fix for newer autotools */ ''
    sed -i {.,zlib}/configure.in \
      -e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-ansi"
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    zlib
  ];

  meta = with stdenv.lib; {
    description = "Id3 library for C/C++";
    homepage = http://id3lib.sourceforge.net/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
