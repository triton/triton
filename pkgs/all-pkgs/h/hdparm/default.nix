{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hdparm-9.53";

  src = fetchurl {
    url = "mirror://sourceforge/hdparm/hdparm/${name}.tar.gz";
    sha256 = "2673f591df6916c6a1faec07069a7eb1cb8ee307615a615d808192fb0c0265e5";
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
