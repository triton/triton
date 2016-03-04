{ stdenv
, fetchurl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libpng-${version}";
  version = "1.6.21";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${version}.tar.xz";
    sha256 = "10r0xqasm8fi0dx95bpca63ab4myb8g600ypyndj2r4jxd4ii3vc";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng-${version}-apng.patch.gz";
      sha256 = "0wwcc52yzjaxvpfkicz20j7yzpy02hpnsm4jjlvw74gy4qjhx9vd";
    })
  ];

  meta = with stdenv.lib; {
    description = "The official reference implementation for the PNG file format with animation patch";
    homepage = http://www.libpng.org/pub/png/libpng.html;
    license = licenses.libpng;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
