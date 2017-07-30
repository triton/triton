{ stdenv
, fetchurl
, lib

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.7";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.xz";
    sha256 = "2f2cab630bceace24f9dbb7d187cd6cd1f4c9f8a7b682c5f7e49c1e2cb58b217";
  };

  buildInputs = [
    boost
    librevenge
    zlib
  ];

  meta = with lib; {
    description = "Microsoft Works file word processor format import filter library";
    homepage = http://libwps.sourceforge.net/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
