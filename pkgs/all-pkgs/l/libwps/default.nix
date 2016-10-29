{ stdenv
, fetchurl

, boost
, librevenge
, zlib
}:

stdenv.mkDerivation rec {
  name = "libwps-0.4.4";

  src = fetchurl {
    url = "mirror://sourceforge/libwps/libwps/${name}/${name}.tar.gz";
    sha256 = "c22fffd547a7be639839c28d74ed3d77a6f2b74b7639532d578ee062d4bc9011";
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
