{ stdenv
, fetchurl

, cairo
, libkate
, pango
}:

stdenv.mkDerivation rec {
  name = "libtiger-0.3.4";

  src = fetchurl {
    name = "${name}.tar.gz";
    multihash = "QmaLAKQTp1wMHUm25cCVUyj2KFaSmsAFa5zYKyyZw31qmS";
    sha256 = "0rj1bmr9kngrgbxrjbn4f4f9pww0wmf6viflinq7ava7zdav4hkk";
  };

  buildInputs = [
    cairo
    libkate
    pango
  ];

  meta = with stdenv.lib; {
    homepage = http://code.google.com/p/libtiger/;
    description = "A rendering library for Kate streams using Pango and Cairo";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
