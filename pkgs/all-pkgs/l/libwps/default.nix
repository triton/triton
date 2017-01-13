{ stdenv
, fetchurl

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.5";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.xz";
    sha256 = "8e175ab9339d447a285a1533bfdc405432b9a275e4f3a98690ffaf12fe7f4d4a";
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
      x86_64-linux;
  };
}
