{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mhash-0.9.9.9";

  src = fetchurl {
    url = "mirror://sourceforge/mhash/${name}.tar.bz2";
    sha256 = "1w7yiljan8gf1ibiypi6hm3r363imm3sxl1j8hapjdq3m591qljn";
  };

  patches = [
    ./autotools-define-conflict-debian-fix.patch
  ];

  dontDisableStatic = true;

  meta = with stdenv.lib; {
    description = "Hash algorithms library";
    homepage = http://mhash.sourceforge.net;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
