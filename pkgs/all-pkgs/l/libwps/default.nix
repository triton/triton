{ stdenv
, fetchurl
, lib

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.8";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.xz";
    sha256 = "e478e825ef33f6a434a19ff902c5469c9da7acc866ea0d8ab610a8b2aa94177e";
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
