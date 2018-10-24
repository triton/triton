{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hdparm-9.57";

  src = fetchurl {
    url = "mirror://sourceforge/hdparm/hdparm/${name}.tar.gz";
    sha256 = "9d568db955a5428797f0b1677ef7cc8bab7756c6e7ff39f6c4a2b2c3640fe870";
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
