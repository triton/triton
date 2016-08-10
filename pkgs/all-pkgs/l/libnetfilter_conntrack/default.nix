{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_conntrack-${version}";
  version = "1.0.5";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_conntrack/files/${name}.tar.bz2";
    md5Confirm = "6aa1bd3c1d0723235ac897087b4cd4e5";
    sha256 = "0fnpja3g8s38cp7ipija5pvhfgna1gybn0z2bl276nk08fppv7gw";
  };

  buildInputs = [
    libmnl
    libnfnetlink
  ];

  meta = with stdenv.lib; {
    description = "Userspace library providing an API to the in-kernel connection tracking state table";
    homepage = http://netfilter.org/projects/libnetfilter_conntrack/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
