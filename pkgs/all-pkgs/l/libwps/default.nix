{ stdenv
, fetchurl
, lib

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.9";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.xz";
    sha256 = "13beb0c733bb1544a542b6ab1d9d205f218e9a2202d1d4cac056f79f6db74922";
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
