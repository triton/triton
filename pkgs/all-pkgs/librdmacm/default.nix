{ stdenv
, fetchurl

, libibverbs
}:

stdenv.mkDerivation rec {
  name = "librdmacm-1.1.0";

  src = fetchurl {
    url = "https://www.openfabrics.org/downloads/rdmacm/${name}.tar.gz";
    sha256 = "8f10848d4810585d6d70b443abc876c1db8df5e9b8b07e095c7e6eaf4ac380c5";
  };

  buildInputs = [
    libibverbs
  ];

  meta = with stdenv.lib; {
    homepage = https://www.openfabrics.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
