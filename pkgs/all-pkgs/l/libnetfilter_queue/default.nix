{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_queue-1.0.2";

  src = fetchurl {
    url = "ftp://ftp.netfilter.org/pub/libnetfilter_queue/${name}.tar.bz2";
    md5Confirm = "df09befac35cb215865b39a36c96a3fa";
    sha256 = "0chsmj9ky80068vn458ijz9sh4sk5yc08dw2d6b8yddybpmr1143";
  };

  buildInputs = [
    libmnl
    libnfnetlink
  ];

  meta = with stdenv.lib; {
    homepage = "http://www.netfilter.org/projects/libnetfilter_queue/";
    description = "userspace API to packets queued by the kernel packet filter";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
