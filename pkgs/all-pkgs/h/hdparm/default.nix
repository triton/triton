{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hdparm-9.54";

  src = fetchurl {
    url = "mirror://sourceforge/hdparm/hdparm/${name}.tar.gz";
    sha256 = "4d7a684b97ebc1a74f34dc85f8fe9e7b265b94bb5c35e81d53863b7e6483163e";
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
