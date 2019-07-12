{ stdenv
, fetchurl
, lib

, boost
, cppunit
, icu
, lcms2
, librevenge
, libwpd
, libwpg
, zlib
}:

stdenv.mkDerivation rec {
  name = "libcdr-0.1.5";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/libcdr/${name}.tar.xz";
    multihash = "QmUMZrCKWfX4nDTiCPE3ZFW6kmhytcZJsAFuF4P9SK22RS";
    sha256 = "6ace5c499a8be34ad871e825442ce388614ae2d8675c4381756a7319429e3a48";
  };

  buildInputs = [
    boost
    cppunit
    icu
    lcms2
    librevenge
    libwpd
    libwpg
    zlib
  ];

  meta = with lib; {
    description = "Library for parsing CorelDRAW documents";
    homepage = https://wiki.documentfoundation.org/DLP/Libraries/libcdr;
    license = licenses.mpl2;
    maintianers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
