{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hdparm-9.48";

  src = fetchurl {
    url = "mirror://sourceforge/hdparm/${name}.tar.gz";
    multihash = "QmcH8WEhxGatXsDXo7xmYMfYTDrePLKaBj6ySam2D7ZHVm";
    sha256 = "1vpvlkrksfwx8lxq1p1nk3ddyzgrwy3rgxpn9kslchdh3jkv95yf";
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
