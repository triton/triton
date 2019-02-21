{ stdenv
, fetchurl
, lib
}:

let
  version = "4.2.1";
in
stdenv.mkDerivation rec {
  name = "beecrypt-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/beecrypt/beecrypt/${version}/${name}.tar.gz";
    sha256 = "286f1f56080d1a6b1d024003a5fa2158f4ff82cae0c6829d3c476a4b5898c55d";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
