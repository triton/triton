{ stdenv
, fetchurl

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.3";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/${name}.tar.gz";
    sha256 = "1ynp7hvx717n2d9m2817g2p3gj8j10i3grp2lillbv93izdh9v1c";
  };

  buildInputs = [
    boost
    librevenge
    zlib
  ];

  meta = with stdenv.lib; {
    inherit version;
    homepage = http://libwps.sourceforge.net/;
    description = "Microsoft Works file word processor format import filter library";
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
