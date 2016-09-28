{ stdenv
, fetchurl

, libpcap
, ncurses
}:

stdenv.mkDerivation rec {
  name = "dnstop-20140915";

  src = fetchurl {
    url = "http://dns.measurement-factory.com/tools/dnstop/src/${name}.tar.gz";
    multihash = "QmSsXR2eD1Ms2x92sXAenLfpAfPHyZkxPbPMUy62fDm6tr";
    sha256 = "b4b03d02005b16e98d923fa79957ea947e3aa6638bb267403102d12290d0c57a";
  };

  buildInputs = [
    libpcap
    ncurses
  ];

  preInstall = ''
    mkdir -pv $out/{bin,share/man/man8}
  '';

  meta = with stdenv.lib; {
    description = "Application that displays DNS traffic on your network";
    homepage = http://dns.measurement-factory.com/tools/dnstop;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
