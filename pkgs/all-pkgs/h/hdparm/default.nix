{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hdparm-9.51";

  src = fetchurl {
    url = "mirror://sourceforge/hdparm/hdparm/${name}.tar.gz";
    sha256 = "1afad8891ecbe644c283f7d725157660ebf8bd5b4d9d67232afd45f83d2d5d91";
  };

  preBuild = ''
    makeFlagsArray=(
      "sbindir=$out/bin"
      "manprefix=$out"
    )
  '';

  meta = with stdenv.lib; {
    description = "A tool to get/set ATA/SATA drive parameters under Linux";
    homepage = http://sourceforge.net/projects/hdparm/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
