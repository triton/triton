{ stdenv, fetchurl, bison, m4 }:

stdenv.mkDerivation rec {
  name = "flex-2.6.0";

  src = fetchurl {
    url = "mirror://sourceforge/flex/${name}.tar.bz2";
    sha256 = "1sdqx63yadindzafrq1w31ajblf9gl1c301g068s20s7bbpi3ri4";
  };

  nativeBuildInputs = [ m4 bison ];

  meta = {
    homepage = http://flex.sourceforge.net/;
    description = "A fast lexical analyser generator";
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
