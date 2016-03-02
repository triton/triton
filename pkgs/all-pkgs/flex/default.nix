{ stdenv
, bison
, fetchurl
, m4
}:

stdenv.mkDerivation rec {
  name = "flex-2.6.0";

  src = fetchurl {
    url = "mirror://sourceforge/flex/${name}.tar.bz2";
    sha256 = "1sdqx63yadindzafrq1w31ajblf9gl1c301g068s20s7bbpi3ri4";
  };

  nativeBuildInputs = [
    bison
    m4
  ];

  # Using static libraries fixes issues with references to
  # yylex in flex 2.6.0
  # This can be tested by building glusterfs
  configureFlags = [
    "--disable-shared"
  ];

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    homepage = http://flex.sourceforge.net/;
    description = "A fast lexical analyser generator";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
