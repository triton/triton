{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hdparm-9.50";

  src = fetchurl {
    url = "mirror://sourceforge/hdparm/hdparm/${name}.tar.gz";
    sha256 = "0892b44bd817c251264a24f6ecbbb010958033e0395d2030f25f1c5608ac780e";
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
