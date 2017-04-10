{ stdenv
, fetchurl
, lib

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.6";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.xz";
    sha256 = "e48a7c2fd20048a0a8eaf69bad972575f8b9f06e7497c787463f127d332fccd0";
  };

  buildInputs = [
    boost
    librevenge
    zlib
  ];

  meta = with lib; {
    inherit version;
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
