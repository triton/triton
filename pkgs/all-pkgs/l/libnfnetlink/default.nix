{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libnfnetlink-1.0.1";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/libnfnetlink/files/${name}.tar.bz2";
    md5Confirm = "98927583d2016a9fb1936fed992e2c5e";
    sha256 = "06mm2x4b01k3m7wnrxblk9j0mybyr4pfz28ml7944xhjx6fy2w7j";
  };

  meta = with stdenv.lib; {
    description = "Low-level library for netfilter kernel/userspace communication";
    homepage = http://www.netfilter.org/projects/libnfnetlink/index.html;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
