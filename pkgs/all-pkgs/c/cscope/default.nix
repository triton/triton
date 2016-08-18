{ stdenv
, fetchurl

, ncurses
}:

stdenv.mkDerivation rec {
  name = "cscope-15.8b";

  src = fetchurl {
    url = "mirror://sourceforge/cscope/${name}.tar.gz";
    multihash = "QmcgB2sqVaZNGsd58y7RHzBWR5xyF5Q5jwopKXZ61MpddJ";
    sha256 = "4889d091f05aa0845384b1e4965aa31d2b20911fb2c001b2cdcffbcb7212d3af";
  };

  buildInputs = [
    ncurses
  ];

  preBuild = ''
    sed -i 's,-lcurses,-lncurses,g' src/Makefile
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
