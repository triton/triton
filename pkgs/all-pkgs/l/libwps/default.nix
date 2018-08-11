{ stdenv
, fetchurl
, lib

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.10";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.xz";
    sha256 = "1421e034286a9f96d3168a1c54ea570ee7aa008ca07b89de005ad5ce49fb29ca";
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
