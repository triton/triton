{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "libaio-0.3.110";

  src = fetchurl {
    url = "https://fedorahosted.org/releases/l/i/libaio/${name}.tar.gz";
    multihash = "QmPxxZxeCD1Dmgkbtr8DFwyBDEU7tY9E7cpP2tXVWJAedE";
    sha256 = "0zjzfkwd1kdvq6zpawhzisv7qbq1ffs343i5fs9p498pcf7046g0";
  };

  preBuild = ''
    makeFlagsArray+=("prefix=$out")
  '';

  meta = with lib; {
    description = "Library for asynchronous I/O in Linux";
    homepage = http://lse.sourceforge.net/io/aio.html;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
