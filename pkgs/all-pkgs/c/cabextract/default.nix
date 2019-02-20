{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "cabextract-1.9";

  src = fetchurl {
    url = "https://www.cabextract.org.uk/${name}.tar.gz";
    multihash = "QmRAF8Pxh3t9zUXtvm6PZDfZCiLe9uGRrafXSRe3b7sYWH";
    sha256 = "1bbc793d83c73288acd7e28ce33ec04955a76c73bf6471424ff835d725fcc4c1";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
